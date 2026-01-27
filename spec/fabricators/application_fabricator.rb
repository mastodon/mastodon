# frozen_string_literal: true

Fabricator(:application, from: Doorkeeper::Application) do
  name         'Example'
  website      'http://example.com'
  redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
end
