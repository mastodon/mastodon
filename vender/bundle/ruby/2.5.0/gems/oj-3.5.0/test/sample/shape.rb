
module Sample
  class Shape
    include HasProps

    attr_accessor :bounds
    attr_accessor :color
    attr_accessor :border, :border_color

    def initialize(left, top, wide, high, color=nil)
      @bounds = [[left, top], [left + wide, top + high]]
      @color = color
      @border = 1
      @border_color = :black
    end
    
    def left
      @bounds[0][0]
    end
    
    def top
      @bounds[0][1]
    end
    
    def width
      @bounds[1][0] - @bounds[0][0]
    end
    
    def height
      @bounds[1][1] - @bounds[0][1]
    end
    
  end # Shape
end # Sample

