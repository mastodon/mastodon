module OEmbed
  # Contains oEmbed data about a URL, as returned by an OEmbed::Provider. The data
  # stored in Response instances can be accessed by either using the field method
  # _or_ by using the appropriate automatically-defined helper method.
  # 
  # For example:
  #   @response.type #=> 'rich'
  #   @response.field('width') #=> '500'
  #   @response.width #=> '500'
  class Response
    # An Hash of data (probably from a Provider) just as it was parsed.
    attr_reader :fields
    
    # The Provider instance that generated this Response
    attr_reader :provider
    
    # The URL that was sent to the provider, that this Response contains data about.
    attr_reader :request_url
    
    # The name of the format used get this data from the Provider (e.g. 'json').
    attr_reader :format

    # Create a new Response instance of the correct type given raw
    # which is data from the provider, about the url, in the given
    # format that needs to be decoded.
    def self.create_for(raw, provider, url, format)
      fields = OEmbed::Formatter.decode(format, raw)

      resp_type = case fields['type']
        when 'photo' then OEmbed::Response::Photo
        when 'video' then OEmbed::Response::Video
        when 'link'  then OEmbed::Response::Link
        when 'rich'  then OEmbed::Response::Rich
        else              self
      end

      resp_type.new(fields, provider, url, format)
    end

    def initialize(fields, provider, url=nil, format=nil)
      @fields = fields
      @provider = provider
      @request_url = url
      @format = format
      define_methods!
    end

    # The String value associated with this key. While you can use helper methods
    # like Response#version, the field method is helpful if the Provider returns
    # non-standard values that conflict with Ruby methods.
    #
    # For example, if the Provider returns a "clone" value of "true":
    #   # The following calls the Object#clone method
    #   @response.clone #=> #<OEmbed::Response:...
    #
    #   # The following returns the value given by the Provider
    #   @response.field(:clone) #=> 'true'
    def field(key)
      @fields[key.to_s].to_s
    end

    # Returns true if this is an oEmbed video response.
    def video?
      is_a?(OEmbed::Response::Video)
    end

    # Returns true if this is an oEmbed photo response.
    def photo?
      is_a?(OEmbed::Response::Photo)
    end

    # Returns true if this is an oEmbed link response.
    def link?
      is_a?(OEmbed::Response::Link)
    end

    # Returns true if this is an oEmbed rich response.
    def rich?
      is_a?(OEmbed::Response::Rich)
    end

    private

    # An Array of helper methods names define_methods! must be able to override
    # when is's called. In general, define_methods! tries its best _not_ to override
    # existing methods, so this Array is important if some other library has
    # defined a method that uses an oEmbed name. For example: Object#version
    def must_override
      %w{
        type version
        title author_name author_url provider_name provider_url
        cache_age thumbnail_url thumbnail_width thumbnail_height
      }
    end

    def define_methods!
      @fields.keys.each do |key|
        next if self.respond_to?(key) && !must_override.include?(key.to_s)
        class << self
          self
        end.send(:define_method, key) do
          field(key)
        end
      end
    end
  end
end
