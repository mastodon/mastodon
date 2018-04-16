module Hamlit
  module HamlHelpers
    # This module overrides Haml helpers to work properly
    # in the context of ActionView.
    # Currently it's only used for modifying the helpers
    # to work with Rails' XSS protection methods.
    module XssMods
      def self.included(base)
        %w[html_escape find_and_preserve preserve list_of surround
           precede succeed capture_haml haml_concat haml_internal_concat haml_indent
           escape_once].each do |name|
          base.send(:alias_method, "#{name}_without_haml_xss", name)
          base.send(:alias_method, name, "#{name}_with_haml_xss")
        end
      end

      # Don't escape text that's already safe,
      # output is always HTML safe
      def html_escape_with_haml_xss(text)
        str = text.to_s
        return text if str.html_safe?
        ::Hamlit::HamlUtil.html_safe(html_escape_without_haml_xss(str))
      end

      # Output is always HTML safe
      def find_and_preserve_with_haml_xss(*args, &block)
        ::Hamlit::HamlUtil.html_safe(find_and_preserve_without_haml_xss(*args, &block))
      end

      # Output is always HTML safe
      def preserve_with_haml_xss(*args, &block)
        ::Hamlit::HamlUtil.html_safe(preserve_without_haml_xss(*args, &block))
      end

      # Output is always HTML safe
      def list_of_with_haml_xss(*args, &block)
        ::Hamlit::HamlUtil.html_safe(list_of_without_haml_xss(*args, &block))
      end

      # Input is escaped, output is always HTML safe
      def surround_with_haml_xss(front, back = front, &block)
        ::Hamlit::HamlUtil.html_safe(
          surround_without_haml_xss(
            haml_xss_html_escape(front),
            haml_xss_html_escape(back),
            &block))
      end

      # Input is escaped, output is always HTML safe
      def precede_with_haml_xss(str, &block)
        ::Hamlit::HamlUtil.html_safe(precede_without_haml_xss(haml_xss_html_escape(str), &block))
      end

      # Input is escaped, output is always HTML safe
      def succeed_with_haml_xss(str, &block)
        ::Hamlit::HamlUtil.html_safe(succeed_without_haml_xss(haml_xss_html_escape(str), &block))
      end

      # Output is always HTML safe
      def capture_haml_with_haml_xss(*args, &block)
        ::Hamlit::HamlUtil.html_safe(capture_haml_without_haml_xss(*args, &block))
      end

      # Input will be escaped unless this is in a `with_raw_haml_concat`
      # block. See #Haml::Helpers::ActionViewExtensions#with_raw_haml_concat.
      def haml_concat_with_haml_xss(text = "")
        raw = instance_variable_defined?(:@_haml_concat_raw) ? @_haml_concat_raw : false
        if raw
          haml_internal_concat_raw text
        else
          haml_internal_concat text
        end
        ErrorReturn.new("haml_concat")
      end

      # Input is escaped
      def haml_internal_concat_with_haml_xss(text="", newline=true, indent=true)
        haml_internal_concat_without_haml_xss(haml_xss_html_escape(text), newline, indent)
      end
      private :haml_internal_concat_with_haml_xss

      # Output is always HTML safe
      def haml_indent_with_haml_xss
        ::Hamlit::HamlUtil.html_safe(haml_indent_without_haml_xss)
      end

      # Output is always HTML safe
      def escape_once_with_haml_xss(*args)
        ::Hamlit::HamlUtil.html_safe(escape_once_without_haml_xss(*args))
      end

      private

      # Escapes the HTML in the text if and only if
      # Rails XSS protection is enabled *and* the `:escape_html` option is set.
      def haml_xss_html_escape(text)
        return text unless ::Hamlit::HamlUtil.rails_xss_safe? && haml_buffer.options[:escape_html]
        html_escape(text)
      end
    end

    class ErrorReturn
      # Any attempt to treat ErrorReturn as a string should cause it to blow up.
      alias_method :html_safe, :to_s
      alias_method :html_safe?, :to_s
      alias_method :html_safe!, :to_s
    end
  end
end
