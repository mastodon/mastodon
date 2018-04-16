module Aws
  module Json
    class OjEngine

      def self.load(json)
        Oj.load(json)
      end

      def self.dump(value)
        Oj.dump(value)
      end

    end
  end
end
