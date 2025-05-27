# frozen_string_literal: true

Fabricator :client_credentials_token, from: :access_token do
  resource_owner_id { nil }
  expires_in { nil }
  revoked_at { nil }
end
