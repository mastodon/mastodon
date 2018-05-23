module Hashie
  module Extensions
    module Dash
      module IndifferentAccess
        def self.included(base)
          base.extend ClassMethods
          base.send :include, Hashie::Extensions::IndifferentAccess
        end

        module ClassMethods
          # Check to see if the specified property has already been
          # defined.
          def property?(name)
            name = translations[name.to_sym] if included_modules.include?(Hashie::Extensions::Dash::PropertyTranslation) && translation_exists?(name)
            name = name.to_s
            !!properties.find { |property| property.to_s == name }
          end

          def translation_exists?(name)
            name = name.to_s
            !!translations.keys.find { |key| key.to_s == name }
          end

          def transformed_property(property_name, value)
            transform = transforms[property_name] || transforms[property_name.to_sym]
            transform.call(value)
          end

          def transformation_exists?(name)
            name = name.to_s
            !!transforms.keys.find { |key| key.to_s == name }
          end
        end
      end
    end
  end
end
