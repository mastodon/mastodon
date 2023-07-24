# frozen_string_literal: true

OmniAuth.config.test_mode = true

def mock_omniauth(provider, data)
  OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(data)
end
