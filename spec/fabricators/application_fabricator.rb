Fabricator(:application, from: Doorkeeper::Application) do
  name         'Example'
  website      'http://example.com'
  redirect_uri 'http://example.com/callback'
end
