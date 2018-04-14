module Paperclip
  module Interpolations
    class PluralCache
      def initialize
        @symbol_cache = {}.compare_by_identity
        @klass_cache = {}.compare_by_identity
      end

      def pluralize_symbol(symbol)
        @symbol_cache[symbol] ||= symbol.to_s.downcase.pluralize
      end

      def underscore_and_pluralize_class(klass)
        @klass_cache[klass] ||= klass.name.underscore.pluralize
      end
    end
  end
end
