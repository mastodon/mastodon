redirect_uri = Hello.mastodon_builder_redirect_uri

client_secret = nil
if ENV['HELLO_MASTODON_BUILDER_CLIENT_SECRET']
  client_secret = ENV['HELLO_MASTODON_BUILDER_CLIENT_SECRET']
else
  puts "The HELLO_MASTODON_BUILDER_CLIENT_SECRET env var must be set"
end

Doorkeeper::Application.create(
  name: 'Hellō Mastodon Builder',
  uid: 'hello-mastodon-builder',
  secret: client_secret,
  redirect_uri: redirect_uri,
  scopes: 'read read:accounts read:follows read:statuses write write:accounts write:follows write:statuses',
  website: 'https://hello.coop/',
)

category = CustomEmojiCategory.find_or_create_by(name: 'System')

Dir.glob('lib/assets/hello/emoji/*.png') do |filename|
  shortcode = File.basename(filename, '.*')
  image_data = File.read(filename)

  e = CustomEmoji.new(shortcode: shortcode, domain: nil)
  e.image = StringIO.new(image_data)
  e.image_file_name = File.basename(filename)
  e.visible_in_picker = true
  e.category = category

  e.save
end
