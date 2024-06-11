# frozen_string_literal: true

Fabricator :accessible_access_token, from: :access_token do
  expires_in { nil }
  revoked_at { nil }
end
