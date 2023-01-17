# frozen_string_literal: true

class Api::Hello::TwitterWebhookController < Api::BaseController
  def crc
    consumer_secret = ENV.fetch('TWITTER_CONSUMER_SECRET', nil)

    if consumer_secret.blank?
      Rails.logger.error '[ERROR] TWITTER_CONSUMER_SECRET env var not set'
      render json: {}, status: 500 and return
    end

    crc_token = params['crc_token']

    if crc_token.blank?
      render json: {}, status: 400 and return
    end

    response_token = generate_crc_response(consumer_secret, crc_token)

    render json: { response_token: response_token }, status: 200
  end

  def generate_crc_response(consumer_secret, crc_token)
    hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)

    Base64.encode64(hash).strip!
  end

  def activity
    # TODO validate signature from HTTP header

    Rails.logger.info "Twitter event: #{params.to_s}"
    render plain: 'OK', status: 200
  end
end
