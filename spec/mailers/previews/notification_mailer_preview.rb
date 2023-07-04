# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer

class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/mention
  def mention
    activity = Mention.last
    mailer_for(activity.account, activity).mention
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow
  def follow
    activity = Follow.last
    mailer_for(activity.target_account, activity).follow
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow_request
  def follow_request
    activity = Follow.last
    mailer_for(activity.target_account, activity).follow_request
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/favourite
  def favourite
    activity = Favourite.last
    mailer_for(activity.status.account, activity).favourite
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reblog
  def reblog
    activity = Status.where.not(reblog_of_id: nil).first
    mailer_for(activity.reblog.account, activity).reblog
  end

  private

  def mailer_for(account, activity)
    NotificationMailer.with(
      recipient: account,
      notification: Notification.find_by(activity: activity)
    )
  end
end
