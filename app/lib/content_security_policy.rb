# frozen_string_literal: true

class ContentSecurityPolicy
  def base_host
    Rails.configuration.x.web_domain
  end
end
