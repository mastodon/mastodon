# frozen_string_literal: true

module Paperclip
  class LazyThumbnail < Paperclip::Thumbnail
    def make
      return File.open(@file.path) unless needs_convert?

      min_side = [@current_geometry.width, @current_geometry.height].min
      options[:geometry] = "#{min_side.to_i}x#{min_side.to_i}#" if @target_geometry.square? && min_side < @target_geometry.width

      Paperclip::Thumbnail.make(file, options, attachment)
    end

    private

    def needs_convert?
      needs_different_geometry? || needs_different_format?
    end

    def needs_different_geometry?
      !@target_geometry.nil? && @current_geometry.width != @target_geometry.width && @current_geometry.height != @target_geometry.height
    end

    def needs_different_format?
      @format.present? && @current_format != @format
    end
  end
end
