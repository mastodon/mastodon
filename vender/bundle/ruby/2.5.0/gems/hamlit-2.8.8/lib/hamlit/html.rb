# frozen_string_literal: true
module Hamlit
  class HTML < Temple::HTML::Fast
    DEPRECATED_FORMATS = %i[html4 html5].freeze

    def initialize(opts = {})
      if DEPRECATED_FORMATS.include?(opts[:format])
        opts = opts.dup
        opts[:format] = :html
      end
      super(opts)
    end
  end
end
