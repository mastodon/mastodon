# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_pending_account
  def new_pending_account
    AdminMailer.new_pending_account(Account.first, User.pending.first)
  end
end
