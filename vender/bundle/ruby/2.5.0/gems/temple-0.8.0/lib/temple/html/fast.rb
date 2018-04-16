module Temple
  module HTML
    # @api public
    class Fast < Filter
      DOCTYPES = {
        xml: {
          '1.1'          => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
          '5'            => '<!DOCTYPE html>',
          'html'         => '<!DOCTYPE html>',
          'strict'       => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
          'frameset'     => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
          'mobile'       => '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
          'basic'        => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
          'transitional' => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
          'svg'          => '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
        },
        html: {
          '5'            => '<!DOCTYPE html>',
          'html'         => '<!DOCTYPE html>',
          'strict'       => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
          'frameset'     => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',
          'transitional' => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
        }
      }
      DOCTYPES[:xhtml] = DOCTYPES[:xml]
      DOCTYPES.freeze

      # See http://www.w3.org/html/wg/drafts/html/master/single-page.html#void-elements
      HTML_VOID_ELEMENTS = %w[area base br col embed hr img input keygen link menuitem meta param source track wbr]

      define_options format: :xhtml,
                     attr_quote: '"',
                     autoclose: HTML_VOID_ELEMENTS,
                     js_wrapper: nil

      def initialize(opts = {})
        super
        @format = options[:format]
        unless [:xhtml, :html, :xml].include?(@format)
          if @format == :html4 || @format == :html5
            warn "Format #{@format.inspect} is deprecated, use :html"
            @format = :html
          else
            raise ArgumentError, "Invalid format #{@format.inspect}"
          end
        end
        wrapper = options[:js_wrapper]
        wrapper = @format == :xml || @format == :xhtml ? :cdata : :comment if wrapper == :guess
        @js_wrapper =
          case wrapper
          when :comment
            [ "<!--\n", "\n//-->" ]
          when :cdata
            [ "\n//<![CDATA[\n", "\n//]]>\n" ]
          when :both
            [ "<!--\n//<![CDATA[\n", "\n//]]>\n//-->" ]
          when nil
          when Array
            wrapper
          else
            raise ArgumentError, "Invalid JavaScript wrapper #{wrapper.inspect}"
          end
      end

      def on_html_doctype(type)
        type = type.to_s.downcase

        if type =~ /^xml(\s+(.+))?$/
          raise(FilterError, 'Invalid xml directive in html mode') if @format == :html
          w = options[:attr_quote]
          str = "<?xml version=#{w}1.0#{w} encoding=#{w}#{$2 || 'utf-8'}#{w} ?>"
        else
          str = DOCTYPES[@format][type] || raise(FilterError, "Invalid doctype #{type}")
        end

        [:static, str]
      end

      def on_html_comment(content)
        [:multi,
          [:static, '<!--'],
          compile(content),
          [:static, '-->']]
      end

      def on_html_condcomment(condition, content)
        on_html_comment [:multi,
                         [:static, "[#{condition}]>"],
                         content,
                         [:static, '<![endif]']]
      end

      def on_html_tag(name, attrs, content = nil)
        name = name.to_s
        closed = !content || (empty_exp?(content) && (@format == :xml || options[:autoclose].include?(name)))
        result = [:multi, [:static, "<#{name}"], compile(attrs)]
        result << [:static, (closed && @format != :html ? ' /' : '') + '>']
        result << compile(content) if content
        result << [:static, "</#{name}>"] if !closed
        result
      end

      def on_html_attrs(*attrs)
        [:multi, *attrs.map {|attr| compile(attr) }]
      end

      def on_html_attr(name, value)
        if @format == :html && empty_exp?(value)
          [:static, " #{name}"]
        else
          [:multi,
           [:static, " #{name}=#{options[:attr_quote]}"],
           compile(value),
           [:static, options[:attr_quote]]]
        end
      end

      def on_html_js(content)
        if @js_wrapper
          [:multi,
           [:static, @js_wrapper.first],
           compile(content),
           [:static, @js_wrapper.last]]
        else
          compile(content)
        end
      end
    end
  end
end
