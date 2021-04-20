# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActionController::Base.log_warning_on_csrf_failure = false
end
