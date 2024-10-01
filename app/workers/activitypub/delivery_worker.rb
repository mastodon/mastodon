# frozen_string_literal: true

class ActivityPub::DeliveryWorker
  include Sidekiq::Worker
  include RoutingHelper
  include JsonLdHelper

  STOPLIGHT_FAILURE_THRESHOLD = 10
  STOPLIGHT_COOLDOWN = 60

  sidekiq_options queue: 'push', retry: 16, dead: false

  # Unfortunately, we cannot control Sidekiq's jitter, so add our own
  sidekiq_retry_in do |count|
    # This is Sidekiq's default delay
    delay  = (count**4) + 15
    # Our custom jitter, that will be added to Sidekiq's built-in one.
    # Sidekiq's built-in jitter is `rand(10) * (count + 1)`
    jitter = rand(0.5 * (count**4))
    delay + jitter
  end

  HEADERS = { 'Content-Type' => 'application/activity+json' }.freeze

  def perform(json, source_account_id, inbox_url, options = {})
    @options        = options.with_indifferent_access

    return unless @options[:bypass_availability] || DeliveryFailureTracker.available?(inbox_url)

    @json           = json
    @source_account = Account.find(source_account_id)
    @inbox_url      = inbox_url
    @host           = Addressable::URI.parse(inbox_url).normalized_site
    @performed      = false

    perform_request
  ensure
    if @inbox_url.present?
      if @performed
        failure_tracker.track_success!
      else
        failure_tracker.track_failure!
      end
    end
  end

  private

  def build_request(http_client)
    Request.new(:post, @inbox_url, body: @json, http_client: http_client).tap do |request|
      request.on_behalf_of(@source_account, sign_with: @options[:sign_with])
      request.add_headers(HEADERS)
      request.add_headers({ 'Collection-Synchronization' => synchronization_header }) if ENV['DISABLE_FOLLOWERS_SYNCHRONIZATION'] != 'true' && @options[:synchronize_followers]
    end
  end

  def synchronization_header
    "collectionId=\"#{account_followers_url(@source_account)}\", digest=\"#{@source_account.remote_followers_hash(@inbox_url)}\", url=\"#{account_followers_synchronization_url(@source_account)}\""
  end

  def perform_request
    stoplight_wrapper.run do
      request_pool.with(@host) do |http_client|
        build_request(http_client).perform do |response|
          raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response)

          @performed = true
        end
      end
    end
  end

  def stoplight_wrapper
    Stoplight(@inbox_url)
      .with_threshold(STOPLIGHT_FAILURE_THRESHOLD)
      .with_cool_off_time(STOPLIGHT_COOLDOWN)
  end

  def failure_tracker
    @failure_tracker ||= DeliveryFailureTracker.new(@inbox_url)
  end

  def request_pool
    RequestPool.current
  end
end
