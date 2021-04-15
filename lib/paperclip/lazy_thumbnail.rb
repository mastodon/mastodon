# frozen_string_literal: true

module Paperclip
  class LazyThumbnail < Paperclip::Thumbnail
    def make
      return File.open(@file.path) unless needs_convert?

      if options[:geometry]
        min_side = [@current_geometry.width, @current_geometry.height].min.to_i
        options[:geometry] = "#{min_side}x#{min_side}#" if @target_geometry.square? && min_side < @target_geometry.width
      elsif options[:pixels]
        width  = Math.sqrt(options[:pixels] * (@current_geometry.width.to_f / @current_geometry.height)).round.to_i
        height = Math.sqrt(options[:pixels] * (@current_geometry.height.to_f / @current_geometry.width)).round.to_i
        options[:geometry] = "#{width}x#{height}>"
      end

      Paperclip::Thumbnail.make(file, options, attachment)
    end

    private

    def needs_convert?
      needs_different_geometry? || needs_different_format? || needs_metadata_stripping?
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
  end
end
