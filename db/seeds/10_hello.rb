redirect_uri = 'https://wallet.hello.coop/oauth/response/mastodon/'
if ENV['HELLO_MASTODON_BUILDER_REDIRECT_URI']
  redirect_uri = ENV['HELLO_MASTODON_BUILDER_REDIRECT_URI']
end

client_secret = nil
if ENV['HELLO_MASTODON_BUILDER_CLIENT_SECRET']
  client_secret = ENV['HELLO_MASTODON_BUILDER_CLIENT_SECRET']
end


Doorkeeper::Application.create!(
  name: 'Hellō Mastodon Builder',
  uid: 'hello-mastodon-builder',
  secret: client_secret,
  redirect_uri: redirect_uri,
  scopes: 'read write follow',
  website: 'https://hello.coop/',
  owner_type: 'User',
  owner_id: 1
)

Rule.create!(text: 'Real names only.')
Rule.create!(text: 'Be kind.')
