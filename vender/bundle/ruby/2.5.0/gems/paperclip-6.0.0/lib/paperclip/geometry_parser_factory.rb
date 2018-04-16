module Paperclip
  class GeometryParser
    FORMAT = /\b(\d*)x?(\d*)\b(?:,(\d?))?(\@\>|\>\@|[\>\<\#\@\%^!])?/i
    def initialize(string)
      @string = string
    end

    def make
      if match
        Geometry.new(
          :height => @height,
          :width => @width,
          :modifier => @modifier,
          :orientation => @orientation
        )
      end
    end

    private

    def match
      if actual_match = @string && @string.match(FORMAT)
        @width = actual_match[1]
        @height = actual_match[2]
        @orientation = actual_match[3]
        @modifier = actual_match[4]
      end
      actual_match
    end
  end
end
