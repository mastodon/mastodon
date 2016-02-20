Rails.application.routes.draw do
  mount Mastodon::API => '/api/'
end
