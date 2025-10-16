# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActionController::Base.action_on_open_redirect = :log
end
