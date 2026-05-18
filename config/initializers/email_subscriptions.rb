# frozen_string_literal: true

Rails.application.configure do
  config.x.email_subscriptions = ENV['DISABLE_EMAIL_SUBSCRIPTIONS'] != 'true'
end
