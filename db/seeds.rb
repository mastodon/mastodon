# frozen_string_literal: true

Chewy.strategy(:mastodon) do
  Dir[Rails.root.join('db', 'seeds', '*.rb')].each do |seed|
    load seed
  end
end
