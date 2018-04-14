module OEmbed
  class Response
    # A fairly generic type of Response where the url of the resource is
    # the original request_url.
    class Link < self
      
      # Returns the request_url
      def url
        request_url
      end
      
      private
      
      # See {section 2.3.4.1 of the oEmbed spec}[http://oembed.com/#section2.3]
      def must_override
        super
      end
    end
  end
end