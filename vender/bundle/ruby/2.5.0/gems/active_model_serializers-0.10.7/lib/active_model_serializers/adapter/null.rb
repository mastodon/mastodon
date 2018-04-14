module ActiveModelSerializers
  module Adapter
    class Null < Base
      def serializable_hash(*)
        {}
      end
    end
  end
end
