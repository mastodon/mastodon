# Be sure to restart your server when you modify this file.

Rails.application.configure do
  frontends = []
  Rails.root.join('app', 'javascript', 'packs', 'frontends').each_child(false) { |f| frontends.push f.to_s }
  config.x.available_frontends = frontends
end
