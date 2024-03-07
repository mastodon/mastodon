module UserSubscriptionExtensions
  extend ActiveSupport::Concern
  included do
    after_create_commit :associate_subscription

    def associate_subscription
      if invite_id.present?
        Subscription::AssociateSubscriptionWorker.perform_async(id, invite_id)
      end

      true
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  if defined? User
    User.include(UserSubscriptionExtensions)
  end
end