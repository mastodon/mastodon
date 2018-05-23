module Hashie
  module Extensions
    # IgnoreUndeclared is a simple mixin that silently ignores
    # undeclared properties on initialization instead of
    # raising an error. This is useful when using a Trash to
    # capture a subset of a larger hash.
    #
    # Note that attempting to retrieve or set an undeclared property
    # will still raise a NoMethodError, even if a value for
    # that property was provided at initialization.
    #
    # @example
    #   class Person < Trash
    #     include Hashie::Extensions::IgnoreUndeclared
    #
    #     property :first_name
    #     property :last_name
    #   end
    #
    #   user_data = {
    #      :first_name => 'Freddy',
    #      :last_name => 'Nostrils',
    #      :email => 'freddy@example.com'
    #   }
    #
    #   p = Person.new(user_data) # 'email' is silently ignored
    #
    #   p.first_name # => 'Freddy'
    #   p.last_name  # => 'Nostrils'
    #   p.email      # => NoMethodError
    module IgnoreUndeclared
      def initialize_attributes(attributes)
        return unless attributes
        klass = self.class
        translations = klass.respond_to?(:translations) && klass.translations
        attributes.each_pair do |att, value|
          next unless klass.property?(att) || (translations && translations.include?(att))
          self[att] = value
        end
      end

      def property_exists?(property)
        self.class.property?(property)
      end
    end
  end
end
