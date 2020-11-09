# frozen_string_literal: true

require 'kramdown/converter'
require 'kramdown/utils'

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

      def host_to_url(str)
        "http#{Rails.configuration.x.use_https ? 's' : ''}://#{str}" unless str.blank?
      end

      def convert_img(el, _opts)
        base_host = Rails.configuration.x.web_domain

        assets_host   = Rails.configuration.action_controller.asset_host
        assets_host ||= host_to_url(base_host)

        media_host   = host_to_url(ENV['S3_ALIAS_HOST'])
        media_host ||= host_to_url(ENV['S3_CLOUDFRONT_HOST'])
        media_host ||= host_to_url(ENV['S3_HOSTNAME']) if ENV['S3_ENABLED'] == 'true'
        media_host ||= assets_host

        src = el.attr['src']
        unless src.start_with?( media_host, ENV['IMAGE_PROXY_HOST'] || 'https://images.weserv.nl/')
          src = "#{ENV['IMAGE_PROXY_PATH'] || 'https://images.weserv.nl/?n=-1&il&url='}#{src}"
        end
        el.attr['src'] = src
        "<img#{html_attributes(el.attr)} />"
      end

      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr)
        hl_opts = {}
        highlighted_code = highlight_code(el.value, el.options[:lang] || lang, :block, hl_opts)
        highlighted_code = highlighted_code == nil ? highlighted_code : highlighted_code.gsub(/[\r\n]/, '<br>')

        if highlighted_code
          add_syntax_highlighter_to_class_attr(attr, lang || hl_opts[:default_lang])
          "#{' ' * indent}<div#{html_attributes(attr)}>#{highlighted_code}#{' ' * indent}</div>\n"
        else
          result = escape_html(el.value)
          result.chomp!
          if el.attr['class'].to_s =~ /\bshow-whitespaces\b/
            result.gsub!(/(?:(^[ \t]+)|([ \t]+$)|([ \t]+))/) do |m|
              suffix = ($1 ? '-l' : ($2 ? '-r' : ''))
              m.scan(/./).map do |c|
                case c
                when "\t" then "<span class=\"ws-tab#{suffix}\">\t</span>"
                when " " then "<span class=\"ws-space#{suffix}\">&#8901;</span>"
                end
              end.join('')
            end
          end
          code_attr = {}
          code_attr['class'] = "language-#{lang}" if lang
          "#{' ' * indent}<pre#{html_attributes(attr)}>" \
            "<code#{html_attributes(code_attr)}>#{result}\n</code></pre>\n"
        end
      end

    end
  end
end