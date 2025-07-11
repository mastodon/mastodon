# frozen_string_literal: true

class Admin::DistributeAnnouncementNotificationWorker
  include Sidekiq::IterableJob
  include BulkMailingConcern

  def build_enumerator(announcement_id, cursor:)
    @announcement = Announcement.find(announcement_id)

    active_record_batches_enumerator(@announcement.scope_for_notification, cursor:)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def each_iteration(batch_of_users, _announcement_id)
    push_bulk_mailer(UserMailer, :announcement_published, batch_of_users.map { |user| [user, @announcement] })
  end
end
