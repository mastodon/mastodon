# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer

class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_report
  def new_report
    admin_mail.new_report(latest_report)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_appeal
  def new_appeal
    admin_mail.new_appeal(latest_appeal)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_pending_account
  def new_pending_account
    admin_mail.new_pending_account(latest_pending_user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_trends
  def new_trends
    admin_mail.new_trends(latest_trending_links, latest_trending_tags, latest_trending_statuses)
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_software_updates
  delegate :new_software_updates, to: :admin_mail

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/new_critical_software_updates
  delegate :new_critical_software_updates, to: :admin_mail

  private

  def latest_trending_links
    PreviewCard.joins(:trend).limit(3)
  end

  def latest_trending_tags
    Tag.limit(3)
  end

  def latest_trending_statuses
    Status.joins(:trend).where(reblog_of_id: nil).limit(3)
  end

  def latest_pending_user
    User.pending.first || Fabricate(:user, approved: false)
  end

  def latest_report
    Report.order(created_at: :desc).first || Fabricate(:report)
  end

  def latest_appeal
    Appeal.where.associated(:account).order(created_at: :desc).first || Fabricate(:appeal)
  end

  def admin_mail
    AdminMailer.with(recipient: admin_account)
  end

  def admin_account
    load_admin_account || fabricate_admin_account
  end

  def load_admin_account
    Account.joins(user: :role).where(user: { role: admin_user_role }).first
  end

  def fabricate_admin_account
    Fabricate(:account, user: Fabricate(:user, role: admin_user_role))
  end

  def admin_user_role
    UserRole.find_by(name: 'Admin')
  end
end
