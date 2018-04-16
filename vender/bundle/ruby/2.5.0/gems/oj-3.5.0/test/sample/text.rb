
module Sample
  class Text < Shape
    attr_accessor :text
    attr_accessor :font
    attr_accessor :font_size
    attr_accessor :just
    attr_accessor :text_color

    def initialize(text, left, top, wide, high, color=nil)
      super(left, top, wide, high, color)
      @text = text
      @font = 'helvetica'
      @font_size = 14
      @just = 'left'
      @text_color = 'black'
    end

  end # Text
end # Sample
