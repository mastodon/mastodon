# frozen_string_literal: true

Rails.application.configure do
  config.x.ffmpeg_binary = ENV['FFMPEG_BINARY'] || 'ffmpeg'
  config.x.ffprobe_binary = ENV['FFPROBE_BINARY'] || 'ffprobe'
end
