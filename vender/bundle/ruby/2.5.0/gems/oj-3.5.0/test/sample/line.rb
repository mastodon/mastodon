module Sample

  class Line
    include HasProps

    attr_accessor :x, :y, :dx, :dy
    attr_accessor :color
    attr_accessor :thick
    
    def initialize(x, y, dx, dy, thick, color)
      @x = x
      @y = y
      @dx = dx
      @dy = dy
      @thick = thick
      @color = color
    end

  end # Line
end # Sample
