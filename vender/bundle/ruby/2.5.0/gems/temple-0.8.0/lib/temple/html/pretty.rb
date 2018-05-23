module Temple
  module HTML
    # @api public
    class Pretty < Fast
      define_options indent: '  ',
                     pretty: true,
                     indent_tags: %w(article aside audio base body datalist dd div dl dt
                                     fieldset figure footer form head h1 h2 h3 h4 h5 h6
                                     header hgroup hr html li link meta nav ol option p
                                     rp rt ruby section script style table tbody td tfoot
                                     th thead tr ul video doctype).freeze,
                     pre_tags: %w(code pre textarea).freeze

      def initialize(opts = {})
        super
        @indent_next = nil
        @indent = 0
        @pretty = options[:pretty]
        @pre_tags = @format != :xml && Regexp.union(options[:pre_tags].map {|t| "<#{t}" })
      end

      def call(exp)
        @pretty ? [:multi, preamble, compile(exp)] : super
      end

      def on_static(content)
        return [:static, content] unless @pretty
        unless @pre_tags && @pre_tags =~ content
          content = content.sub(/\A\s*\n?/, "\n".freeze) if @indent_next
          content = content.gsub("\n".freeze, indent)
        end
        @indent_next = false
        [:static, content]
      end

      def on_dynamic(code)
        return [:dynamic, code] unless @pretty
        indent_next, @indent_next = @indent_next, false
        [:dynamic, "::Temple::Utils.indent_dynamic((#{code}), #{indent_next.inspect}, #{indent.inspect}#{@pre_tags ? ', ' + @pre_tags_name : ''})"]
      end

      def on_html_doctype(type)
        return super unless @pretty
        [:multi, [:static, tag_indent('doctype')], super]
      end

      def on_html_comment(content)
        return super unless @pretty
        result = [:multi, [:static, tag_indent('comment')], super]
        @indent_next = false
        result
      end

      def on_html_tag(name, attrs, content = nil)
        return super unless @pretty

        name = name.to_s
        closed = !content || (empty_exp?(content) && options[:autoclose].include?(name))

        @pretty = false
        result = [:multi, [:static, "#{tag_indent(name)}<#{name}"], compile(attrs)]
        result << [:static, (closed && @format != :html ? ' /' : '') + '>']

        @pretty = !@pre_tags || !options[:pre_tags].include?(name)
        if content
          @indent += 1
          result << compile(content)
          @indent -= 1
        end
        unless closed
          indent = tag_indent(name)
          result << [:static, "#{content && !empty_exp?(content) ? indent : ''}</#{name}>"]
        end
        @pretty = true
        result
      end

      protected

      def preamble
        return [:multi] unless @pre_tags
        @pre_tags_name = unique_name
        [:code, "#{@pre_tags_name} = /#{@pre_tags.source}/"]
      end

      def indent
        "\n" + (options[:indent] || '') * @indent
      end

      # Return indentation before tag
      def tag_indent(name)
        if @format == :xml
          flag = @indent_next != nil
          @indent_next = true
        else
          flag = @indent_next != nil && (@indent_next || options[:indent_tags].include?(name))
          @indent_next = options[:indent_tags].include?(name)
        end
        flag ? indent : ''
      end
    end
  end
end
