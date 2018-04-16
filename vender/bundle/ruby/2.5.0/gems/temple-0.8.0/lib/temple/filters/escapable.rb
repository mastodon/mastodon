module Temple
  module Filters
    # Escape dynamic or static expressions.
    # This filter must be used after Temple::HTML::* and before the generators.
    # It can be enclosed with Temple::Filters::DynamicInliner filters to
    # reduce calls to Temple::Utils#escape_html.
    #
    # @api public
    class Escapable < Filter
      # Activate the usage of html_safe? if it is available (for Rails 3 for example)
      define_options :escape_code,
                     :disable_escape,
                     use_html_safe: ''.respond_to?(:html_safe?)

      def initialize(opts = {})
        super
        @escape_code = options[:escape_code] ||
          "::Temple::Utils.escape_html#{options[:use_html_safe] ? '_safe' : ''}((%s))"
        @escaper = eval("proc {|v| #{@escape_code % 'v'} }")
        @escape = false
      end

      def on_escape(flag, exp)
        old = @escape
        @escape = flag && !options[:disable_escape]
        compile(exp)
      ensure
        @escape = old
      end

      def on_static(value)
        [:static, @escape ? @escaper[value] : value]
      end

      def on_dynamic(value)
        [:dynamic, @escape ? @escape_code % value : value]
      end
    end
  end
end
