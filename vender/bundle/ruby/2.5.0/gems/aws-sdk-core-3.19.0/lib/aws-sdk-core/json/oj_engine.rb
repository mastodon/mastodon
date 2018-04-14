module Aws
  module Json
    class JSONEngine

      def self.load(json)
        JSON.load(json)
      end

      def self.dump(value)
        JSON.dump(value)
      end

    end
  end
end
