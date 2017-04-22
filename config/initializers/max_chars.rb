# frozen_string_literal: true

Rails.application.configure do
  if ENV['MAX_CHARS'] and not ENV['MAX_CHARS'].empty?
    config.x.max_chars = ENV['MAX_CHARS'].to_i
  else
    config.x.max_chars = 500
  end
end
