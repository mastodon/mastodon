# frozen_string_literal: true

module Subscription
  class AssociateSubscriptionWorker
    include Sidekiq::Worker
    include JsonLdHelper

    sidekiq_options queue: 'default'

    REVENUECAT_STRIPE_API_KEY = ENV['REVENUECAT_STRIPE_API_KEY'] || ''

    def perform(user_id, invite_id)
      sub = Subscription::StripeSubscription.find_by(invite_id: invite_id)
      if sub.present?
        if sub.user.nil?
          sub.update(user_id: user_id)
        else
          sub.members.create(user_id: user_id)
        end

        # post to revenue cat
        body = Oj.dump({ 'app_user_id': user_id, 'fetch_token': sub.subscription_id }.as_json)
        response = HTTP.post('https://api.revenuecat.com/v1/receipts', body: body, headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + REVENUECAT_STRIPE_API_KEY, 'X-Platform' =>  'stripe' })
        raise Mastodon::UnexpectedResponseError, response unless response_successful?(response) || response_error_unsalvageable?(response)
      end
    end
  end
end
