# frozen_string_literal: true

class WebpReader
  attr_reader :animated

  WEBP_HEADER = 'RIFF'

  class WebpReaderException < StandardError; end

  class UnknownImageType < WebpReaderException; end

  def self.animated?(path)
    new(path).animated
  rescue WebpReaderException
    false
  end

  def initialize(path)
    @path = path

    File.open(path, 'rb') do |s|
      raise UnknownImageType unless WEBP_HEADER == s.read(4)

      @animated = s.read(256).include?('ANMF')
    end
  end
end

module Paperclip
  # This transcoder is only to be used for the MediaAttachment model
  # to convert animated webp to videos

  class WebpTranscoder < Paperclip::Processor
    def make
      return File.open(@file.path) unless needs_convert?

      final_file = Paperclip::Transcoder.make(file, options, attachment)

      if options[:style] == :original
        attachment.instance.file_file_name    = "#{File.basename(attachment.instance.file_file_name, '.*')}.mp4"
        attachment.instance.file_content_type = 'video/mp4'
        attachment.instance.type              = MediaAttachment.types[:gifv]
      end

      final_file
    end

    private

    def needs_convert?
      WebpReader.animated?(file.path)
    end
  end
end
