module Fog
  module Attributes
    # = Fog String Attribute
    #
    # This class handles String attributes from the providers,
    # converting values to String objects
    class String < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_s
            end
        EOS
      end
    end
  end
end
