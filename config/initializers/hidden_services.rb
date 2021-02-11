# frozen_string_literal: true

Rails.application.configure do
  domains = config.x.alternate_domains
  domains << config.x.local_domain
  domains << config.x.web_domain

  config.action_dispatch.always_write_cookie = domains.any? { |domain| domain.end_with?('.onion') }
end
