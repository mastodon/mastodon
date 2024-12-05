# frozen_string_literal: true

# TODO: Starting with Rails 7.0, the framework default is true for this setting.
# This location in devise redirects and we can't hook in or override:
# https://github.com/heartcombo/devise/blob/v4.9.3/app/controllers/devise/confirmations_controller.rb#L28
# When solution is found, this setting can go back to default.
Rails.application.config.action_controller.raise_on_open_redirects = false
