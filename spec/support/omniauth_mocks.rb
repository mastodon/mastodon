# frozen_string_literal: true

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new({
  provider: 'openid_connect',
  uid: '123',
  info: {
    verified: 'true',
    email: 'user@host.example',
  },
})
