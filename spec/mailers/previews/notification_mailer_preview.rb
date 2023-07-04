# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer

class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/mention
  def mention
    m = Mention.last
    NotificationMailer.with(recipient: m.account).mention(Notification.find_by(activity: m))
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow
  def follow
    f = Follow.last
    NotificationMailer.with(recipient: m.target_account).follow(Notification.find_by(activity: f))
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow_request
  def follow_request
    f = Follow.last
    NotificationMailer.with(recipient: f.target_account).follow_request(Notification.find_by(activity: f))
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/favourite
  def favourite
    f = Favourite.last
    NotificationMailer.with(recipient: f.status.account).favourite(Notification.find_by(activity: f))
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reblog
  def reblog
    r = Status.where.not(reblog_of_id: nil).first
    NotificationMailer.with(recipient: r.reblog.account).reblog(Notification.find_by(activity: r))
  end
end
