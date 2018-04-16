# frozen_string_literal: true

class Users::FromProcMailer < Devise::Mailer
  default from: proc { 'custom@example.com' }
end
