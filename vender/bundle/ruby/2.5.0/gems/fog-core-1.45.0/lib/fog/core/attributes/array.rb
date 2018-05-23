module Fog
  module Attributes
    # = Fog Array Attribute
    #
    # This class handles Array attributes from the providers,
    # converting values to Array objects
    class Array < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(new_#{name})
            attributes[:#{name}] = Array(new_#{name})
          end
        EOS
      end

      def create_getter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            Array(attributes[:#{name}])
          end
        EOS
      end
    end
  end
end
