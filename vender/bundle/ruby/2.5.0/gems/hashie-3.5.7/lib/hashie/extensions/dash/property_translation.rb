module Hashie
  module Extensions
    module Dash
      # Extends a Dash with the ability to remap keys from a source hash.
      #
      # Property translation is useful when you need to read data from another
      # application -- such as a Java API -- where the keys are named
      # differently from Ruby conventions.
      #
      # == Example from inconsistent APIs
      #
      #   class PersonHash < Hashie::Dash
      #     include Hashie::Extensions::Dash::PropertyTranslation
      #
      #     property :first_name, from :firstName
      #     property :last_name, from: :lastName
      #     property :first_name, from: :f_name
      #     property :last_name, from: :l_name
      #   end
      #
      #   person = PersonHash.new(firstName: 'Michael', l_name: 'Bleigh')
      #   person[:first_name]  #=> 'Michael'
      #   person[:last_name]   #=> 'Bleigh'
      #
      # You can also use a lambda to translate the value. This is particularly
      # useful when you want to ensure the type of data you're wrapping.
      #
      # == Example using translation lambdas
      #
      #   class DataModelHash < Hashie::Dash
      #     include Hashie::Extensions::Dash::PropertyTranslation
      #
      #     property :id, transform_with: ->(value) { value.to_i }
      #     property :created_at, from: :created, with: ->(value) { Time.parse(value) }
      #   end
      #
      #   model = DataModelHash.new(id: '123', created: '2014-04-25 22:35:28')
      #   model.id.class          #=> Fixnum
      #   model.created_at.class  #=> Time
      module PropertyTranslation
        def self.included(base)
          base.instance_variable_set(:@transforms, {})
          base.instance_variable_set(:@translations_hash, {})
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end

        module ClassMethods
          attr_reader :transforms, :translations_hash

          # Ensures that any inheriting classes maintain their translations.
          #
          # * <tt>:default</tt> - The class inheriting the translations.
          def inherited(klass)
            super
            klass.instance_variable_set(:@transforms, transforms.dup)
            klass.instance_variable_set(:@translations_hash, translations_hash.dup)
          end

          def permitted_input_keys
            @permitted_input_keys ||= properties.map { |property| inverse_translations.fetch property, property }
          end

          # Defines a property on the Trash. Options are as follows:
          #
          # * <tt>:default</tt> - Specify a default value for this property, to be
          # returned before a value is set on the property in a new Dash.
          # * <tt>:from</tt> - Specify the original key name that will be write only.
          # * <tt>:with</tt> - Specify a lambda to be used to convert value.
          # * <tt>:transform_with</tt> - Specify a lambda to be used to convert value
          # without using the :from option. It transform the property itself.
          def property(property_name, options = {})
            super

            if options[:from]
              if property_name == options[:from]
                fail ArgumentError, "Property name (#{property_name}) and :from option must not be the same"
              end

              translations_hash[options[:from]] ||= {}
              translations_hash[options[:from]][property_name] = options[:with] || options[:transform_with]

              define_method "#{options[:from]}=" do |val|
                self.class.translations_hash[options[:from]].each do |name, with|
                  self[name] = with.respond_to?(:call) ? with.call(val) : val
                end
              end
            else
              if options[:transform_with].respond_to? :call
                transforms[property_name] = options[:transform_with]
              end
            end
          end

          def transformed_property(property_name, value)
            transforms[property_name].call(value)
          end

          def transformation_exists?(name)
            transforms.key? name
          end

          def translation_exists?(name)
            translations_hash.key? name
          end

          def translations
            @translations ||= {}.tap do |h|
              translations_hash.each do |(property_name, property_translations)|
                if property_translations.size > 1
                  h[property_name] = property_translations.keys
                else
                  h[property_name] = property_translations.keys.first
                end
              end
            end
          end

          def inverse_translations
            @inverse_translations ||= {}.tap do |h|
              translations_hash.each do |(property_name, property_translations)|
                property_translations.keys.each do |k|
                  h[k] = property_name
                end
              end
            end
          end
        end

        module InstanceMethods
          # Sets a value on the Dash in a Hash-like way.
          #
          # Note: Only works on pre-existing properties.
          def []=(property, value)
            if self.class.translation_exists? property
              send("#{property}=", value)
            elsif self.class.transformation_exists? property
              super property, self.class.transformed_property(property, value)
            elsif property_exists? property
              super
            end
          end

          # Deletes any keys that have a translation
          def initialize_attributes(attributes)
            return unless attributes
            attributes_copy = attributes.dup.delete_if do |k, v|
              if self.class.translations_hash.include?(k)
                self[k] = v
                true
              end
            end
            super attributes_copy
          end

          # Raises an NoMethodError if the property doesn't exist
          def property_exists?(property)
            fail_no_property_error!(property) unless self.class.property?(property)
            true
          end
        end
      end
    end
  end
end
