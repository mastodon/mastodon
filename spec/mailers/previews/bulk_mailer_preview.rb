# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/bulk_mailer
class BulkMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/bulk_mailer/announcement_published
  def announcement_published
    BulkMailer.announcement_published(User.first, Announcement.last)
  end

  # Preview this email at http://localhost:3000/rails/mailers/bulk_mailer/terms_of_service_changed
  def terms_of_service_changed
    BulkMailer.terms_of_service_changed(User.first, TermsOfService.live.first)
  end
end
