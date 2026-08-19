# frozen_string_literal: true

class ActivityPub::LowPriorityDeliveryWorker < ActivityPub::DeliveryWorker
  sidekiq_options queue: 'pull', retry: 8, dead: false

  def perform_request
    stoplight_wrapper.run do
      build_request(nil).perform do |response|
        if response_successful?(response)
          @performed = true
        elsif response_error_unsalvageable?(response) || unsalvageable_authorization_failure?(response)
          @unsalvageable = true
        else
          raise Mastodon::UnexpectedResponseError, response
        end
      end
    end
  end
end
