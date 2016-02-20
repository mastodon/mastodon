module Mastodon
  class API < Grape::API
    rescue_from :all

    mount Mastodon::Ostatus
    mount Mastodon::Rest
  end
end
