# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/backup_mailer

class BackupMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/backup_mailer/ready
  def ready
    BackupMailer.with(user: Backup.last.user, backup: Backup.last).ready
  end
end
