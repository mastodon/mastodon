# frozen_string_literal: true

require "forwardable"
require "singleton"

module HTTP
  module MimeType
    # Base encode/decode MIME type adapter
    class Adapter
      include Singleton

      class << self
        extend Forwardable
        def_delegators :instance, :encode, :decode
      end

      %w[encode decode].each do |operation|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{operation}(*)
            fail Error, "\#{self.class} does not supports ##{operation}"
          end
        RUBY
      end
    end
  end
end
