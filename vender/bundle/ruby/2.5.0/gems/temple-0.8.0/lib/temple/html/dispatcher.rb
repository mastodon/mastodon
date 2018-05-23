module Temple
  module HTML
    # @api private
    module Dispatcher
      def on_html_attrs(*attrs)
        [:html, :attrs, *attrs.map {|a| compile(a) }]
      end

      def on_html_attr(name, content)
        [:html, :attr, name, compile(content)]
      end

      def on_html_comment(content)
        [:html, :comment, compile(content)]
      end

      def on_html_condcomment(condition, content)
        [:html, :condcomment, condition, compile(content)]
      end

      def on_html_js(content)
        [:html, :js, compile(content)]
      end

      def on_html_tag(name, attrs, content = nil)
        result = [:html, :tag, name, compile(attrs)]
        content ? (result << compile(content)) : result
      end
    end
  end
end
