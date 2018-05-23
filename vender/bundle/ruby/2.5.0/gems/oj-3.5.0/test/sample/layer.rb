
module Sample
  class Layer < Group
    attr_accessor :name

    def initialize(name)
      super()
      @name = name
    end

  end # Layer
end # Sample
