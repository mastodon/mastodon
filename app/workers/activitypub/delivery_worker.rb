# frozen_string_literal: true

class ActivityPub::DeliveryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 5, dead: false

  HEADERS = { 'Content-Type' => 'application/activity+json' }.freeze

  def perform(json, source_account_id, inbox_url)
    @json           = json
    @source_account = Account.find(source_account_id)
    @inbox_url      = inbox_url

    perform_request

    raise Mastodon::UnexpectedResponseError, @response unless response_successful?
  rescue => e
    raise e.class, "Delivery failed for #{inbox_url}: #{e.message}"
  end

  private

  def build_request
    request = Request.new(:post, @inbox_url, body: @json)
    request.on_behalf_of(@source_account, :uri)
    request.add_headers(HEADERS)
  end

  def perform_request
    @response = build_request.perform
  end

  def response_successful?
    @response.code > 199 && @response.code < 300
  end
end
