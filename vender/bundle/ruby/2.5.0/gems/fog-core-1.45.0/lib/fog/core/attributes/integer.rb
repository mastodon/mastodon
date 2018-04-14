module Fog
  module Attributes
    # = Fog Integer Attribute
    #
    # This class handles Integer attributes from the providers,
    # converting values to Integer objects
    class Integer < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_i
            end
        EOS
      end
    end
  end
end
