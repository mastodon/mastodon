module Loofah
  module Helpers
    class << self
      #
      #  A replacement for Rails's built-in +strip_tags+ helper.
      #
      #   Loofah::Helpers.strip_tags("<div>Hello <b>there</b></div>") # => "Hello there"
      #
      def strip_tags(string_or_io)
        Loofah.fragment(string_or_io).text
      end

      #
      #  A replacement for Rails's built-in +sanitize+ helper.
      #
      #   Loofah::Helpers.sanitize("<script src=http://ha.ckers.org/xss.js></script>") # => "&lt;script src=\"http://ha.ckers.org/xss.js\"&gt;&lt;/script&gt;"
      #
      def sanitize(string_or_io)
        loofah_fragment = Loofah.fragment(string_or_io)
        loofah_fragment.scrub!(:strip)
        loofah_fragment.xpath("./form").each { |form| form.remove }
        loofah_fragment.to_s
      end

      #
      #  A replacement for Rails's built-in +sanitize_css+ helper.
      #
      #    Loofah::Helpers.sanitize_css("display:block;background-image:url(http://www.ragingplatypus.com/i/cam-full.jpg)") # => "display: block;"
      #
      def sanitize_css style_string
        ::Loofah::HTML5::Scrub.scrub_css style_string
      end

      #
      #  A helper to remove extraneous whitespace from text-ified HTML
      #  TODO: remove this in a future major-point-release.
      #
      def remove_extraneous_whitespace(string)
        Loofah.remove_extraneous_whitespace string
      end
    end

    module ActionView
      module ClassMethods # :nodoc:
        def full_sanitizer
          @full_sanitizer ||= ::Loofah::Helpers::ActionView::FullSanitizer.new
        end

        def white_list_sanitizer
          @white_list_sanitizer ||= ::Loofah::Helpers::ActionView::WhiteListSanitizer.new
        end
      end

      #
      #  Replacement class for Rails's HTML::FullSanitizer.
      #
      #  To use by default, call this in an application initializer:
      #
      #    ActionView::Helpers::SanitizeHelper.full_sanitizer = ::Loofah::Helpers::ActionView::FullSanitizer.new
      #
      #  Or, to generally opt-in to Loofah's view sanitizers:
      #
      #    Loofah::Helpers::ActionView.set_as_default_sanitizer
      #
      class FullSanitizer
        def sanitize html, *args
          Loofah::Helpers.strip_tags html
        end
      end

      #
      #  Replacement class for Rails's HTML::WhiteListSanitizer.
      #
      #  To use by default, call this in an application initializer:
      #
      #    ActionView::Helpers::SanitizeHelper.white_list_sanitizer = ::Loofah::Helpers::ActionView::WhiteListSanitizer.new
      #
      #  Or, to generally opt-in to Loofah's view sanitizers:
      #
      #    Loofah::Helpers::ActionView.set_as_default_sanitizer
      #
      class WhiteListSanitizer
        def sanitize html, *args
          Loofah::Helpers.sanitize html
        end

        def sanitize_css style_string, *args
          Loofah::Helpers.sanitize_css style_string
        end
      end
    end
  end
end
