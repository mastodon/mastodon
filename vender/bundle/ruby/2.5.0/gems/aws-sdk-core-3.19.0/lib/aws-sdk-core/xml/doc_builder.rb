module Aws
  module Xml
    class DocBuilder

      # @option options [#<<] :target ('')
      # @option options [String] :pad ('')
      # @option options [String] :indent ('')
      def initialize(options = {})
        @target = options[:target] || ''
        @indent = options[:indent] || ''
        @pad = options[:pad] || ''
        @end_of_line = @indent == '' ? '' : "\n"
      end

      attr_reader :target

      # @overload node(name, attributes = {})
      #   Adds a self closing element without any content.
      #
      # @overload node(name, value, attributes = {})
      #   Adds an element that opens and closes on the same line with
      #   simple text content.
      #
      # @overload node(name, attributes = {}, &block)
      #   Adds a wrapping element.  Calling {#node} from inside
      #   the yielded block creates nested elements.
      #
      # @return [void]
      #
      def node(name, *args, &block)
        attrs = args.last.is_a?(Hash) ? args.pop : {}
        if block_given?
          @target << open_el(name, attrs)
          @target << @end_of_line
          increase_pad { yield }
          @target << @pad
          @target << close_el(name)
        elsif args.empty?
          @target << empty_element(name, attrs)
        else
          @target << inline_element(name, args.first, attrs)
        end
      end

      private

      def empty_element(name, attrs)
        "#{@pad}<#{name}#{attributes(attrs)}/>#{@end_of_line}"
      end

      def inline_element(name, value, attrs)
        "#{open_el(name, attrs)}#{escape(value, :text)}#{close_el(name)}"
      end

      def open_el(name, attrs)
        "#{@pad}<#{name}#{attributes(attrs)}>"
      end

      def close_el(name)
        "</#{name}>#{@end_of_line}"
      end

      def escape(string, text_or_attr)
        string.to_s.encode(:xml => text_or_attr)
      end

      def attributes(attr)
        if attr.empty?
          ''
        else
          ' ' + attr.map do |key, value|
            "#{key}=#{escape(value, :attr)}"
          end.join(' ')
        end
      end

      def increase_pad(&block)
        pre_increase = @pad
        @pad = @pad + @indent
        yield
        @pad = pre_increase
      end

    end
  end
end
