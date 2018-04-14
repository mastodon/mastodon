module Hashie
  module Extensions
    module Dash
      module Coercion
        # Extends a Dash with the ability to define coercion for properties.

        def self.included(base)
          base.send :include, Hashie::Extensions::Coercion
          base.extend ClassMethods
        end

        module ClassMethods
          # Defines a property on the Dash. Options are the standard
          # <tt>Hashie::Dash#property</tt> options plus:
          #
          # * <tt>:coerce</tt> - The class into which you want the property coerced.
          def property(property_name, options = {})
            super
            coerce_key property_name, options[:coerce] if options[:coerce]
          end
        end
      end
    end
  end
end
