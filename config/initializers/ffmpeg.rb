# frozen_string_literal: true

Rails.application.configure do
  config.x.ffmpeg_binary = ENV.fetch('FFMPEG_BINARY', 'ffmpeg')
  config.x.ffprobe_binary = ENV.fetch('FFPROBE_BINARY', 'ffprobe')
end
