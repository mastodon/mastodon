# frozen_string_literal: true

class Web::PushNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push', retry: 5

  TTL     = 48.hours.to_s
  URGENCY = 'normal'

  def perform(subscription_id, notification_id)
    @subscription = Web::PushSubscription.find(subscription_id)
    @notification = Notification.find(notification_id)

    # Polymorphically associated activity could have been deleted
    # in the meantime, so we have to double-check before proceeding
    return unless @notification.activity.present? && @subscription.pushable?(@notification)

    payload = @subscription.encrypt(push_notification_json)

    request_pool.with(@subscription.audience) do |http_client|
      request = Request.new(:post, @subscription.endpoint, body: payload.fetch(:ciphertext), http_client: http_client)

      request.add_headers(
        'Content-Type'     => 'application/octet-stream',
        'Ttl'              => TTL,
        'Urgency'          => URGENCY,
        'Content-Encoding' => 'aesgcm',
        'Encryption'       => "salt=#{Webpush.encode64(payload.fetch(:salt)).delete('=')}",
        'Crypto-Key'       => "dh=#{Webpush.encode64(payload.fetch(:server_public_key)).delete('=')};#{@subscription.crypto_key_header}",
        'Authorization'    => @subscription.authorization_header
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

  def push_notification_json
    json = I18n.with_locale(@subscription.locale.presence || I18n.default_locale) do
      ActiveModelSerializers::SerializableResource.new(
        @notification,
        serializer: Web::NotificationSerializer,
        scope: @subscription,
        scope_name: :current_push_subscription
      ).as_json
    end

    Oj.dump(json)
  end

  def request_pool
    RequestPool.current
  end
end
