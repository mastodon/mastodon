require 'cgi'

module Seahorse
  # @api private
  module Util
    class << self

      def uri_escape(string)
        CGI.escape(string.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
      end

      def uri_path_escape(path)
        path.gsub(/[^\/]+/) { |part| uri_escape(part) }
      end

    end
  end
end
