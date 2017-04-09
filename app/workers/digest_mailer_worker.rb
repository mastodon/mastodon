# frozen_string_literal: true

class DigestMailerWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'mailers'

  def perform(user_id)
    user = User.find(user_id)
    return unless user.settings.notification_emails['digest']
    NotificationMailer.digest(user.account).deliver_now!
    user.touch(:last_emailed_at)
  end
end
