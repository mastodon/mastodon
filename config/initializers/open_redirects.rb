# frozen_string_literal: true

# We override a devise method in a way which leads to an open redirect
# Prefer logging only instead of raise for open redirects
Rails.application.config.action_controller.action_on_open_redirect = :log
