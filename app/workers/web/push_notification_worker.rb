# frozen_string_literal: true

class Web::PushNotificationWorker
  include Sidekiq::Worker
  include RoutingHelper

  sidekiq_options queue: 'push', retry: 5

  TTL     = 48.hours
  URGENCY = 'normal'

  def perform(subscription_id, notification_id)
    @subscription = Web::PushSubscription.find(subscription_id)
    @notification = Notification.find(notification_id)

    return if @notification.updated_at < TTL.ago

    # Polymorphically associated activity could have been deleted
    # in the meantime, so we have to double-check before proceeding
    return unless @notification.activity.present? && @subscription.pushable?(@notification)

    payload = web_push_request.encrypt(push_notification_json)

    request_pool.with(web_push_request.audience) do |http_client|
      request = Request.new(:post, web_push_request.endpoint, body: payload.fetch(:ciphertext), http_client: http_client)

      request.add_headers(
        'Content-Type' => 'application/octet-stream',
        'Ttl' => TTL.to_s,
        'Urgency' => URGENCY,
        'Content-Encoding' => 'aesgcm',
        'Encryption' => "salt=#{Webpush.encode64(payload.fetch(:salt)).delete('=')}",
        'Crypto-Key' => "dh=#{Webpush.encode64(payload.fetch(:server_public_key)).delete('=')};#{web_push_request.crypto_key_header}",
        'Authorization' => web_push_request.authorization_header,
        'Unsubscribe-URL' => subscription_url
      )

      request.perform do |response|
        # If the server responds with an error in the 4xx range
        # that isn't about rate-limiting or timeouts, we can
        # assume that the subscription is invalid or expired
        # and must be removed

        if (400..499).cover?(response.code) && ![408, 429].include?(response.code)
          @subscription.destroy!
        elsif !(200...300).cover?(response.code)
          raise Mastodon::UnexpectedResponseError, response
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def web_push_request
    @web_push_request || WebPushRequest.new(@subscription)
  end

  def push_notification_json
    I18n.with_locale(@subscription.locale.presence || I18n.default_locale) do
      Oj.dump(serialized_notification.as_json)
    end
  end

  def serialized_notification
    ActiveModelSerializers::SerializableResource.new(
      @notification,
      serializer: Web::NotificationSerializer,
      scope: @subscription,
      scope_name: :current_push_subscription
    )
  end

  def request_pool
    RequestPool.current
  end

  def subscription_url
    api_web_push_subscription_url(id: @subscription.generate_token_for(:unsubscribe))
  end
end
