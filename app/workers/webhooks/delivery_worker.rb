# frozen_string_literal: true

class Webhooks::DeliveryWorker
  include Sidekiq::Worker
  include JsonLdHelper

  sidekiq_options queue: 'push', retry: 16, dead: false

  def perform(webhook_id, body)
    @webhook   = Webhook.find(webhook_id)
    @body      = body
    @response  = nil

    perform_request
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def perform_request
    request = Request.new(:post, @webhook.url, body: @body, allow_local: true)

    request.add_headers(
      'Content-Type' => 'application/json',
      'X-Hub-Signature' => "sha256=#{signature}"
    )

    request.perform do |response|
      raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response)
    end
  end

  def signature
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @webhook.secret, @body)
  end
end
