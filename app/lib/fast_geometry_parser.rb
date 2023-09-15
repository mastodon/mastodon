# frozen_string_literal: true

class FastGeometryParser
  def self.from_file(file)
    width, height = FastImage.size(file)

    if width.nil?
      Paperclip::GeometryDetector.new(file).make
    else
      Paperclip::Geometry.new(width, height)
    end
  end
end
