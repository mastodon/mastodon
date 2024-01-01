# frozen_string_literal: true

module Subscription
  class WebhookWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'default'

    def perform(event_id)
      event = ::Stripe::Event.retrieve(event_id)
      case event[:type]
      when 'checkout.session.completed'
        session = ::Stripe::Checkout::Session.retrieve(event[:data][:object][:id])
        subscription = ::Stripe::Subscription.retrieve(session[:subscription])

        max_uses = subscription[:quantity]
        if (max_uses.nil?)
          max_uses = 0
          subscription[:items][:data].each do |item|
            max_uses += item[:quantity]
          end
        end

        invite = if (session[:client_reference_id].present?)
          max_uses -= 1
          Invite.new(user_id: session[:client_reference_id], max_uses: max_uses, autofollow: true)
        else
          instance_user = InstancePresenter.new.contact.account&.user
          Invite.new(user_id: instance_user&.id, max_uses: max_uses, autofollow: true)
        end
        invite.save!

        Subscription::StripeSubscription.create(
          user_id: session[:client_reference_id],
          customer_id: session[:customer],
          subscription_id: session[:subscription],
          status: subscription[:status],
          invite_id: invite.id,
        )

        if (session[:client_reference_id].nil?)
          customer = ::Stripe::Customer.retrieve(session[:customer])
          Subscription::ApplicationMailer.send_invite(customer[:email], invite).deliver_later
        end
      when 'customer.subscription.updated'
        stripe_sub = event[:data][:object]
        subscription = Subscription::StripeSubscription.find_by(subscription_id: stripe_sub[:id])
        subscription.update(status: stripe_sub[:status])

        if (stripe_sub[:canceled_at].present? && event[:data][:previous_attributes].present? && event[:data][:previous_attributes][:canceled_at].nil?)
          customer = ::Stripe::Customer.retrieve(stripe_sub[:customer])
          Subscription::ApplicationMailer.send_canceled(customer[:email], stripe_sub[:cancel_at]).deliver_later
        end
      when 'customer.subscription.deleted'
        stripe_sub = event[:data][:object]
        subscription = Subscription::StripeSubscription.find_by(subscription_id: stripe_sub[:id])
        subscription.update(status: stripe_sub[:status])
      end

    rescue Stripe::InvalidRequestError
      true
    end
  end
end
