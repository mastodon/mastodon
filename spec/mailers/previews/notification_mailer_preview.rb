# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer

class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/mention
  def mention
    activity = Mention.last
    NotificationMailer
      .with(recipient: activity.account, notification: notification_for(activity))
      .mention
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow
  def follow
    activity = Follow.last
    NotificationMailer
      .with(recipient: activity.target_account, notification: notification_for(activity))
      .follow
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow_request
  def follow_request
    activity = Follow.last
    NotificationMailer
      .with(recipient: activity.target_account, notification: notification_for(activity))
      .follow_request
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/favourite
  def favourite
    activity = Favourite.last
    NotificationMailer
      .with(recipient: activity.status.account, notification: notification_for(activity))
      .favourite
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reblog
  def reblog
    activity = Status.where.not(reblog_of_id: nil).first
    NotificationMailer
      .with(recipient: activity.reblog.account, notification: notification_for(activity))
      .reblog
  end

  def notification_for(activity)
    Notification.find_by(activity: activity)
  end
end
