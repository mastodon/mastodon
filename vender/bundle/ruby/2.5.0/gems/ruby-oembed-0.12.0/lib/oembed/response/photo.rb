module OEmbed
  class Response
    # A Response used for representing static photos.
    class Photo < self
      # Returns an <img> tag pointing at the appropraite URL.
      def html
        "<img src='#{self.url}' alt='#{(self.respond_to?(:title) ? self.title : nil)}' />"
      end
      
      private
      
      # See {section 2.3.4.1 of the oEmbed spec}[http://oembed.com/#section2.3]
      def must_override
        %w{
          url width height
        } + super
      end
      
    end
  end
end
