# frozen_string_literal: true

# Since Rails 6.1, ActionView adds preload links for javascript files
# in the Links header per default.

# In our case, that will bloat headers too much and potentially cause
# issues with reverse proxies. Furthermore, we don't need those links,
# as we already output them as HTML link tags.

Rails.application.config.action_view.preload_links_header = false
