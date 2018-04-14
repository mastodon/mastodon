module Hashie
  module Extensions
    module KeyConversion
      def self.included(base)
        base.send :include, SymbolizeKeys
        base.send :include, StringifyKeys
      end
    end
  end
end
