# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_pending_account
  def new_pending_account
    AdminMailer.new_pending_account(Account.first, User.pending.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_trends
  def new_trends
    AdminMailer.new_trends(Account.first, PreviewCard.joins(:trend).limit(3), Tag.limit(3), Status.joins(:trend).where(reblog_of_id: nil).limit(3))
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_appeal
  def new_appeal
    AdminMailer.new_appeal(Account.first, Appeal.first)
  end
end
