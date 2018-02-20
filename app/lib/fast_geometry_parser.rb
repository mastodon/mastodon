# frozen_string_literal: true

class FastGeometryParser
  def self.from_file(file)
    width, height = FastImage.size(file.path)

    raise Paperclip::Errors::NotIdentifiedByImageMagickError if width.nil?

    Paperclip::Geometry.new(width, height)
  end
end
