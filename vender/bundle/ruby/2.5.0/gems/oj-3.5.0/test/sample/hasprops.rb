
module Sample
  module HasProps

    def add_prop(key, value)
      @props = { } unless self.instance_variable_defined?(:@props)
      @props[key] = value
    end

    def props
      @props = { } unless self.instance_variable_defined?(:@props)
      @props
    end
    
  end # HasProps
end # Sample
