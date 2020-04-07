# frozen_string_literal: true

class ActivityPub::DeliveryWorker
  include Sidekiq::Worker
  include JsonLdHelper

  STOPLIGHT_FAILURE_THRESHOLD = 10
  STOPLIGHT_COOLDOWN = 60

  sidekiq_options queue: 'push', retry: 16, dead: false

  HEADERS = { 'Content-Type' => 'application/activity+json' }.freeze

  def perform(json, source_account_id, inbox_url, options = {})
    return unless DeliveryFailureTracker.available?(inbox_url)

    @options        = options.with_indifferent_access
    @json           = json
    @source_account = Account.find(source_account_id)
    @inbox_url      = inbox_url
    @host           = Addressable::URI.parse(inbox_url).normalized_site
    @performed      = false

    perform_request
  ensure
    if @performed
      failure_tracker.track_success!
    else
      failure_tracker.track_failure!
    end
  end

  private

  def build_request(http_client)
    Request.new(:post, @inbox_url, body: @json, http_client: http_client).tap do |request|
      request.on_behalf_of(@source_account, :uri, sign_with: @options[:sign_with])
      request.add_headers(HEADERS)
    end
  end

  def perform_request
    light = Stoplight(@inbox_url) do
      request_pool.with(@host) do |http_client|
        build_request(http_client).perform do |response|
          raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response)

          @performed = true
        end
      end
    end

    begin
      light.with_threshold(STOPLIGHT_FAILURE_THRESHOLD)
           .with_cool_off_time(STOPLIGHT_COOLDOWN)
           .run
    rescue Stoplight::Error::RedLight => e
      raise e.class, e.message, e.backtrace.first(3)
    end
  end

  def failure_tracker
    @failure_tracker ||= DeliveryFailureTracker.new(@inbox_url)
  end

  def request_pool
    RequestPool.current
  end
end
