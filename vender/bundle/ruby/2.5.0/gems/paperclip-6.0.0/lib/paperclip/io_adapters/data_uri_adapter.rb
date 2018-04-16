module Paperclip
  class DataUriAdapter < StringioAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        String === target && target =~ REGEXP
      end
    end

    REGEXP = /\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m

    def initialize(target_uri, options = {})
      super(extract_target(target_uri), options)
    end

    private

    def extract_target(uri)
      data_uri_parts = uri.match(REGEXP) || []
      StringIO.new(Base64.decode64(data_uri_parts[2] || ""))
    end
  end
end
