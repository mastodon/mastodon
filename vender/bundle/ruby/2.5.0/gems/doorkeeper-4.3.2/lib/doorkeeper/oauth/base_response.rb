module Doorkeeper
  module OAuth
    class BaseResponse
      def body
        {}
      end

      def description
        ""
      end

      def headers
        {}
      end

      def redirectable?
        false
      end

      def redirect_uri
        ""
      end

      def status
        :ok
      end
    end
  end
end
