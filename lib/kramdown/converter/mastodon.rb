# frozen_string_literal: true

require 'kramdown/converter'
require 'kramdown/utils'

module Kramdown
  module Converter
    class Mastodon < Html

      def convert_img(el, _indent)
        link_attr = { href: el.attr['src'], target: '_blank', class: 'image-source-link' }
        alt = el.attr['alt'].empty? ? el.attr['src'] : el.attr['alt']

        if ENV['IMAGE_PROXY_HOST'] && ENV['IMAGE_PROXY_PATH']
          el.attr['src'] = "#{ENV['IMAGE_PROXY_PATH']}#{el.attr['src']}"
        else
          # return "Please ask the admin to add the <code>IMAGE_PROXY_PATH</code> option to enable Markdown image preview."
          link_attr.delete(:class)
          return "<a #{html_attributes(link_attr)}><em>Media: #{alt}</em></a>"
        end

        "<img#{html_attributes(el.attr)} /><a #{html_attributes(link_attr)}><em>Media: #{alt}</em></a>"
      end
    end
  end
end
