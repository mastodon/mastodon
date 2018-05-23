module Fog
  module Attributes
    # = Fog Default Attribute
    #
    # This class handles the attributes without a type force.
    # The attributes returned from the provider will keep its original values.
    class Default
      attr_reader :model, :name, :squash, :aliases, :default, :as

      def initialize(model, name, options)
        @model = model
        @model.attributes << name
        @name = name
        @squash = options.fetch(:squash, false)
        @aliases = options.fetch(:aliases, [])
        @default = options[:default]
        @as = options.fetch(:as, name)
        create_setter
        create_getter
        create_aliases
        set_defaults
        create_mask
      end

      def create_setter
        if squash
          model.class_eval <<-EOS, __FILE__, __LINE__
              def #{name}=(new_data)
                if new_data.is_a?(Hash)
                  if new_data.has_key?(:'#{squash}')
                    attributes[:#{name}] = new_data[:'#{squash}']
                  elsif new_data.has_key?("#{squash}")
                    attributes[:#{name}] = new_data["#{squash}"]
                  else
                    attributes[:#{name}] = [ new_data ]
                  end
                else
                  attributes[:#{name}] = new_data
                end
              end
          EOS
        else
          model.class_eval <<-EOS, __FILE__, __LINE__
              def #{name}=(new_#{name})
                attributes[:#{name}] = new_#{name}
              end
          EOS
        end
      end

      def create_getter
        model.class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            return attributes[:#{name}] unless attributes[:#{name}].nil?
            if !attributes.key?(:#{name}) && !self.class.default_values[:#{name}].nil? && !persisted?
              return self.class.default_values[:#{name}]
            end
            attributes[:#{name}]
          end
        EOS
      end

      def create_aliases
        Array(aliases).each do |alias_name|
          model.aliases[alias_name] = name
        end
      end

      def set_defaults
        model.default_values[name] = default unless default.nil?
      end

      def create_mask
        model.masks[name] = as
      end
    end
  end
end
