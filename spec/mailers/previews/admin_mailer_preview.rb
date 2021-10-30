# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_pending_account
  def new_pending_account
    AdminMailer.new_pending_account(Account.first, User.pending.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_trending_tags
  def new_trending_tags
    AdminMailer.new_trending_tags(Account.first, Tag.limit(3))
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_trending_links
  def new_trending_links
    AdminMailer.new_trending_links(Account.first, PreviewCard.limit(3))
  end
end
