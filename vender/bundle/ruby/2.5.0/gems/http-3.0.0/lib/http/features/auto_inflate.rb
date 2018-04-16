# frozen_string_literal: true

module HTTP
  module Features
    class AutoInflate < Feature
      def stream_for(connection, response)
        if %w[deflate gzip x-gzip].include?(response.headers[:content_encoding])
          Response::Inflater.new(connection)
        else
          connection
        end
      end
    end
  end
end
