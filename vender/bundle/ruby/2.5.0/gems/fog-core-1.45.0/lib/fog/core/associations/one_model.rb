module Fog
  module Associations
    # = Fog Single Association
    #
    # This class handles single association between the models.
    # It expects the provider to map the attribute with an initialized object.
    class OneModel < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(new_#{name})
            associations[:#{name}] = new_#{name}
          end
        EOS
      end

      def create_getter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            associations[:#{name}]
          end
        EOS
      end
    end
  end
end
