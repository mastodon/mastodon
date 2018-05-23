# frozen_string_literal: false
require 'hamlit/helpers'

# Currently this Hamlit::Helpers depends on
# ActionView internal implementation. (not desired)
module Hamlit
  module RailsHelpers
    include Helpers
    extend self

    DEFAULT_PRESERVE_TAGS = %w[textarea pre code].freeze

    def find_and_preserve(input = nil, tags = DEFAULT_PRESERVE_TAGS, &block)
      return find_and_preserve(capture_haml(&block), input || tags) if block

      tags = tags.each_with_object('') do |t, s|
        s << '|' unless s.empty?
        s << Regexp.escape(t)
      end

      re = /<(#{tags})([^>]*)>(.*?)(<\/\1>)/im
      input.to_s.gsub(re) do |s|
        s =~ re # Can't rely on $1, etc. existing since Rails' SafeBuffer#gsub is incompatible
        "<#{$1}#{$2}>#{preserve($3)}</#{$1}>"
      end
    end

    def preserve(input = nil, &block)
      return preserve(capture_haml(&block)) if block
      super.html_safe
    end

    def surround(front, back = front, &block)
      output = capture_haml(&block)

      "#{escape_once(front)}#{output.chomp}#{escape_once(back)}\n".html_safe
    end

    def precede(str, &block)
      "#{escape_once(str)}#{capture_haml(&block).chomp}\n".html_safe
    end

    def succeed(str, &block)
      "#{capture_haml(&block).chomp}#{escape_once(str)}\n".html_safe
    end

    def capture_haml(*args, &block)
      capture(*args, &block)
    end
  end
end
