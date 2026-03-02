# frozen_string_literal: true

class Api::V1::DonationCampaignsController < Api::BaseController
  before_action :require_user!

  STOPLIGHT_COOL_OFF_TIME = 60
  STOPLIGHT_FAILURE_THRESHOLD = 10

  def index
    return head 204 if api_url.blank?

    json = from_cache
    return render json: json if json.present?

    campaign = fetch_campaign
    return head 204 if campaign.nil?

    save_to_cache!(campaign)

    render json: campaign
  end

  private

  def api_url
    Rails.configuration.x.donation_campaigns.api_url
  end

  def seed
    @seed ||= Random.new(current_account.id).rand(100)
  end

  def from_cache
    key = Rails.cache.read(request_key, raw: true)
    return if key.blank?

    campaign = Rails.cache.read("donation_campaign:#{key}", raw: true)
    Oj.load(campaign) if campaign.present?
  end

  def save_to_cache!(campaign)
    return if campaign.blank?

    Rails.cache.write_multi(
      {
        request_key => campaign_key(campaign),
        "donation_campaign:#{campaign_key(campaign)}" => Oj.dump(campaign),
      },
      expires_in: 1.hour,
      raw: true
    )
  end

  def fetch_campaign
    stoplight_wrapper.run do
      url = Addressable::URI.parse(api_url)
      url.query_values = { platform: 'web', seed: seed, locale: locale, environment: Rails.configuration.x.donation_campaigns.environment }.compact

      Request.new(:get, url.to_s).perform do |res|
        return Oj.load(res.body_with_limit, mode: :strict) if res.code == 200
      end
    end
  rescue *Mastodon::HTTP_CONNECTION_ERRORS, Oj::ParseError
    nil
  end

  def stoplight_wrapper
    Stoplight(
      'donation_campaigns',
      cool_off_time: STOPLIGHT_COOL_OFF_TIME,
      threshold: STOPLIGHT_FAILURE_THRESHOLD
    )
  end

  def request_key
    "donation_campaign_request:#{seed}:#{locale}"
  end

  def campaign_key(campaign)
    "#{campaign['id']}:#{campaign['locale']}"
  end

  def locale
    I18n.locale.to_s
  end
end
