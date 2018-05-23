module Fog
  module Associations
    # = Fog Multiple Association
    #
    # This class handles multiple association between the models.
    # It expects the provider to return a collection of ids.
    # The association models will be loaded based on the collection of ids.
    class ManyIdentities < Default
      def create_setter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(new_#{name})
            associations[:#{name}] = Array(new_#{name}).map do |association|
                                       association.respond_to?(:identity) ? association.identity : association
                                     end
          end
        EOS
      end

      def create_getter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            return [] if associations[:#{name}].nil?
            data = Array(associations[:#{name}]).map do |association|
              service.send(self.class.associations[:#{name}]).get(association)
            end
            #{association_class}.new(data)
          end
        EOS
      end
    end
  end
end
