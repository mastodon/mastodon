# frozen_string_literal: true

Fabricator :access_token, from: 'Doorkeeper::AccessToken' do
  # This is necessary as for some reason Fabricator doesn't pick up the setting
  # from Doorkeeper automatically:
  use_refresh_token { Doorkeeper.config.refresh_token_enabled? }
end
