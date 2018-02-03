# frozen_string_literal: true

Rails.application.configure do
  config.x.default_hashtag = ENV['DEFAULT_HASHTAG']
  config.x.default_hashtag_id = Tag.find_by(name: ENV['DEFAULT_HASHTAG'].downcase)
end
