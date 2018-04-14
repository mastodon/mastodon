require 'tilt/template'
require 'rdiscount'

module Tilt
  # Discount Markdown implementation. See:
  # http://github.com/rtomayko/rdiscount
  #
  # RDiscount is a simple text filter. It does not support +scope+ or
  # +locals+. The +:smart+ and +:filter_html+ options may be set true
  # to enable those flags on the underlying RDiscount object.
  class RDiscountTemplate < Template
    self.default_mime_type = 'text/html'

    ALIAS = {
      :escape_html => :filter_html,
      :smartypants => :smart
    }

    FLAGS = [:smart, :filter_html, :smartypants, :escape_html]

    def flags
      FLAGS.select { |flag| options[flag] }.map { |flag| ALIAS[flag] || flag }
    end

    def prepare
      @engine = RDiscount.new(data, *flags)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end

    def allows_script?
      false
    end
  end
end

