module OEmbed
  class Response
    # A Response used for representing playable videos.
    class Video < self
      
      private
      
      # See {section 2.3.4.1 of the oEmbed spec}[http://oembed.com/#section2.3]
      def must_override
        %w{
          html width height
        } + super
      end
    end
  end
end