# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/mention
  def mention
    # NotificationMailer.mention
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow
  def follow
    # NotificationMailer.follow
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/favourite
  def favourite
    # NotificationMailer.favourite
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reblog
  def reblog
    # NotificationMailer.reblog
  end

end
