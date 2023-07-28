module UserSubscriptionExtensions
  extend ActiveSupport::Concern
  included do
    after_create_commit :associate_subscription

    def associate_subscription
      if invite_id.present?
        sub = Subscription::StripeSubscription.find_by(invite_id: invite_id)
        if sub.present? && sub.user.nil?
          sub.update(user_id: id)
        end
      end

      true
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  User.include(UserSubscriptionExtensions)
end