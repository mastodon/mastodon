# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_FROM_ADDRESS') { 'notifications@localhost' }
  layout 'mailer'
  helper :instance
end
