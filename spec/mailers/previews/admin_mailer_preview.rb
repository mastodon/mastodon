# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_pending_account
  def new_pending_account
    AdminMailer.with(recipient: Account.first).new_pending_account(User.pending.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_trends
  def new_trends
    AdminMailer.with(recipient: Account.first).new_trends(PreviewCard.joins(:trend).limit(3), Tag.limit(3), Status.joins(:trend).where(reblog_of_id: nil).limit(3))
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_appeal
  def new_appeal
    AdminMailer.with(recipient: Account.first).new_appeal(Appeal.first)
  end
end
