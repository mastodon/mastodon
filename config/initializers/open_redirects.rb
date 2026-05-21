# frozen_string_literal: true

# In the Devise confirmations#show action, a redirect_to is called:
# https://github.com/heartcombo/devise/blob/v5.0.0/app/controllers/devise/confirmations_controller.rb#L28
#
# We override the `after_confirmation_path_for` method in a way which sometimes
# returns raw URLs to external hosts, as part of the auth workflow.
# Discussion: https://github.com/mastodon/mastodon/pull/36505#discussion_r2782876831

Rails.application.reloader.to_prepare do
  ActionController::Base.action_on_open_redirect = :log
end
