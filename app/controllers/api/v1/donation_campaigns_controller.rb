# frozen_string_literal: true

class Api::V1::DonationCampaignsController < Api::BaseController
  include Redisable

  before_action :require_user!

  def index
    return head 204 if api_url.blank?

    with_redis do |redis|
      json = get_from_cache(redis)
      return render json: json if json.present?

      campaign = fetch_campaign
      return head 204 if campaign.nil?

      save_to_cache(redis, campaign)

      render json: campaign
    end
  end

  private

  def api_url
    Rails.configuration.x.donation_campaigns_url
  end

  def seed
    current_account.id % 1_000
  end

  def get_from_cache(redis)
    key = redis.get(request_key)
    return if key.blank?

    campaign = redis.get("donation_campaign:#{key}")
    Oj.load(campaign) if campaign.present?
  end

  def save_to_cache(redis, campaign)
    return if campaign.blank?

    redis.pipelined do |pipeline|
      pipeline.set(request_key, campaign_key(campaign), ex: 1.hour)
      pipeline.set("donation_campaign:#{campaign_key(campaign)}", Oj.dump(campaign), ex: 1.hour)
    end
  end

  def fetch_campaign
    url = Addressable::URI.parse(api_url)
    url.query_values = { platform: 'web', seed: seed, locale: locale }

    Request.new(:get, url.to_s).perform do |res|
      return Oj.load(res.body_with_limit, mode: :strict) if res.code == 200
    end
  rescue *Mastodon::HTTP_CONNECTION_ERRORS, Oj::ParseError
    nil
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
