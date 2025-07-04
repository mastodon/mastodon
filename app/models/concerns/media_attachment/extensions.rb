# frozen_string_literal: true

module MediaAttachment::Extensions
  extend ActiveSupport::Concern

  AUDIO_FILE_EXTENSIONS = %w(
    .3gp
    .aac
    .flac
    .m4a
    .mp3
    .oga
    .ogg
    .opus
    .wav
    .wma
  ).freeze

  IMAGE_FILE_EXTENSIONS = %w(
    .avif
    .gif
    .heic
    .heif
    .jpeg
    .jpg
    .png
    .webp
  ).freeze

  VIDEO_FILE_EXTENSIONS = %w(
    .m4v
    .mov
    .mp4
    .webm
  ).freeze

  class_methods do
    def supported_file_extensions
      [
        AUDIO_FILE_EXTENSIONS,
        IMAGE_FILE_EXTENSIONS,
        VIDEO_FILE_EXTENSIONS,
      ]
        .flatten
        .sort
    end
  end
end
