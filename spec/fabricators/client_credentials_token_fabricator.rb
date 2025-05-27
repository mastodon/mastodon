# frozen_string_literal: true

Fabricator :client_credentials_token, from: :accessible_access_token do
  resource_owner_id { nil }
end
