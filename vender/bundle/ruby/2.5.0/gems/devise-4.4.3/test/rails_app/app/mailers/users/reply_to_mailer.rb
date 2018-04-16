# frozen_string_literal: true

class Users::ReplyToMailer < Devise::Mailer
  default from: 'custom@example.com'
  default reply_to: 'custom_reply_to@example.com'
end
