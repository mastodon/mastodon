# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class EmailSubscriptionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email_subscription_mailer/confirmation
  def confirmation
    EmailSubscriptionMailer.with(subscription: EmailSubscription.last!).confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/email_subscription_mailer/notification
  def notification
    EmailSubscriptionMailer.with(subscription: EmailSubscription.last!).notification(Status.where(visibility: :public).without_replies.without_reblogs.limit(5))
  end
end
