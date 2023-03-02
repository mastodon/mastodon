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
      raise UnknownImageType unless s.read(4) == WEBP_HEADER

      @animated = s.read(256).include?('ANIM')
    end
  end
end

module Paperclip
  class WebpTranscoder < Paperclip::Thumbnail
    def make
      return File.open(@file.path) unless needs_convert?

      if animated?
        @format = 'mp4'

        attachment.instance.file_file_name = "#{File.basename(attachment.instance.file_file_name, '.*')}.mp4"
        attachment.instance.file_content_type = 'video/mp4'
        attachment.instance.type = MediaAttachment.types[:gifv]
      end

      super
    end

    private

    def animated?
      options[:style] == :original && WebpReader.animated?(file.path)
    end

    def needs_convert?
      needs_different_geometry? || needs_different_format? || needs_metadata_stripping? || WebpReader.animated?(file.path)
    end

    def needs_different_geometry?
      (options[:geometry] && @current_geometry.width != @target_geometry.width && @current_geometry.height != @target_geometry.height) ||
        (options[:pixels] && @current_geometry.width * @current_geometry.height > options[:pixels])
    end

    def needs_different_format?
      @format.present? && @current_format != @format
    end

    def needs_metadata_stripping?
      @attachment.instance.respond_to?(:local?) && @attachment.instance.local?
    end

    def transformation_command
      # To get rid of glitch, Remove "-layers optimize" form the command
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      trans = []
      trans << '-coalesce' if animated?
      trans << '-auto-orient' if auto_orient
      trans << '-resize' << %("#{scale}") if scale.present?
      trans << '-crop' << %("#{crop}") << '+repage' if crop
      trans
    end
  end
end
