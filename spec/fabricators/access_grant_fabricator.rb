# frozen_string_literal: true

Fabricator :access_grant, from: 'Doorkeeper::AccessGrant' do
  application
  resource_owner_id { Fabricate(:user).id }
  expires_in 3_600
  redirect_uri { Doorkeeper.configuration.native_redirect_uri }
end
