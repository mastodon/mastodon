module Fog
  module Attributes
    # = Fog Float Attribute
    #
    # This class handles Float attributes from the providers,
    # converting values to Float objects
    class Float < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_f
            end
        EOS
      end
    end
  end
end
