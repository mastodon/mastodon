# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 40
  config.window = 4
  config.outer_window = 4
end
