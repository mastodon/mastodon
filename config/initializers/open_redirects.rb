# frozen_string_literal: true

# TODO
# Starting with Rails 7.0, the framework default here is to set this true.
# However, we have a location in devise that redirects where we don't have an
# easy ability to override the method or set a config option, and where the
# redirect does not supply this option itself.
# https://github.com/heartcombo/devise/blob/v4.9.2/app/controllers/devise/confirmations_controller.rb#L28
# Once a solution is found, this line can be removed.
Rails.application.config.action_controller.raise_on_open_redirects = false
