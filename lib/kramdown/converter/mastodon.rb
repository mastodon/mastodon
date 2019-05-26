# frozen_string_literal: true

require 'kramdown/converter'

module Kramdown
  module Converter
    class Mastodon < Html
      def convert_text(element, _indent)
        html = Formatter.instance.send(:encode_and_link_urls, element.value, @options[:linkable_accounts])

        if @options[:custom_emojis]
          Formatter.instance.send(:encode_custom_emojis, html, @options[:custom_emojis], @options[:autoplay])
        else
          html
        end
      end
    end
  end
end
