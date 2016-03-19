class ApplicationMailer < ActionMailer::Base
  default from: (ENV['SMTP_FROM_ADDRESS'] || 'notifications@localhost')
  layout 'mailer'
end
