# frozen_string_literal: true

class BackupWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(backup_id)
    backup = Backup.find(backup_id)
    user   = backup.user

    BackupService.new.call(backup)

    user.backups.where.not(id: backup.id).destroy_all
    UserMailer.backup_ready(user, backup).deliver_later
  end
end
