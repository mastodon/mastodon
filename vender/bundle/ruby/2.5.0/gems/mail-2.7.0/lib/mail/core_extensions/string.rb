# encoding: utf-8
# frozen_string_literal: true
class String #:nodoc:

  unless method_defined?(:ascii_only?)
    # Backport from Ruby 1.9 checks for non-us-ascii characters.
    def ascii_only?
      self !~ MATCH_NON_US_ASCII
    end

    MATCH_NON_US_ASCII = /[^\x00-\x7f]/
  end

  unless method_defined?(:bytesize)
    alias :bytesize :length
  end
end
