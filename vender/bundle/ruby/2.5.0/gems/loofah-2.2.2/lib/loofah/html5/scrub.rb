require 'cgi'
require 'crass'

module Loofah
  module HTML5 # :nodoc:
    module Scrub

      CONTROL_CHARACTERS = /[`\u0000-\u0020\u007f\u0080-\u0101]/
      CSS_KEYWORDISH = /\A(#[0-9a-f]+|rgb\(\d+%?,\d*%?,?\d*%?\)?|-?\d{0,2}\.?\d{0,2}(cm|em|ex|in|mm|pc|pt|px|%|,|\))?)\z/
      CRASS_SEMICOLON = {:node => :semicolon, :raw => ";"}

      class << self

        def allowed_element? element_name
          ::Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS_WITH_LIBXML2.include? element_name
        end

        #  alternative implementation of the html5lib attribute scrubbing algorithm
        def scrub_attributes node
          node.attribute_nodes.each do |attr_node|
            attr_name = if attr_node.namespace
                          "#{attr_node.namespace.prefix}:#{attr_node.node_name}"
                        else
                          attr_node.node_name
                        end

            if attr_name =~ /\Adata-[\w-]+\z/
              next
            end

            unless WhiteList::ALLOWED_ATTRIBUTES.include?(attr_name)
              attr_node.remove
              next
            end

            if WhiteList::ATTR_VAL_IS_URI.include?(attr_name)
              # this block lifted nearly verbatim from HTML5 sanitization
              val_unescaped = CGI.unescapeHTML(attr_node.value).gsub(CONTROL_CHARACTERS,'').downcase
              if val_unescaped =~ /^[a-z0-9][-+.a-z0-9]*:/ && ! WhiteList::ALLOWED_PROTOCOLS.include?(val_unescaped.split(WhiteList::PROTOCOL_SEPARATOR)[0])
                attr_node.remove
                next
              elsif val_unescaped.split(WhiteList::PROTOCOL_SEPARATOR)[0] == 'data'
                # permit only allowed data mediatypes
                mediatype = val_unescaped.split(WhiteList::PROTOCOL_SEPARATOR)[1]
                mediatype, _ = mediatype.split(';')[0..1] if mediatype
                if mediatype && !WhiteList::ALLOWED_URI_DATA_MEDIATYPES.include?(mediatype)
                  attr_node.remove
                  next
                end
              end
            end
            if WhiteList::SVG_ATTR_VAL_ALLOWS_REF.include?(attr_name)
              attr_node.value = attr_node.value.gsub(/url\s*\(\s*[^#\s][^)]+?\)/m, ' ') if attr_node.value
            end
            if WhiteList::SVG_ALLOW_LOCAL_HREF.include?(node.name) && attr_name == 'xlink:href' && attr_node.value =~ /^\s*[^#\s].*/m
              attr_node.remove
              next
            end
          end

          scrub_css_attribute node

          node.attribute_nodes.each do |attr_node|
            node.remove_attribute(attr_node.name) if attr_node.value !~ /[^[:space:]]/
          end

          force_correct_attribute_escaping! node
        end

        def scrub_css_attribute node
          style = node.attributes['style']
          style.value = scrub_css(style.value) if style
        end

        def scrub_css style
          style_tree = Crass.parse_properties style
          sanitized_tree = []

          style_tree.each do |node|
            next unless node[:node] == :property
            next if node[:children].any? do |child|
              [:url, :bad_url].include?(child[:node]) || (child[:node] == :function && !WhiteList::ALLOWED_CSS_FUNCTIONS.include?(child[:name].downcase))
            end
            name = node[:name].downcase
            if WhiteList::ALLOWED_CSS_PROPERTIES.include?(name) || WhiteList::ALLOWED_SVG_PROPERTIES.include?(name)
              sanitized_tree << node << CRASS_SEMICOLON
            elsif WhiteList::SHORTHAND_CSS_PROPERTIES.include?(name.split('-').first)
              value = node[:value].split.map do |keyword|
                if WhiteList::ALLOWED_CSS_KEYWORDS.include?(keyword) || keyword =~ CSS_KEYWORDISH
                  keyword
                end
              end.compact
              unless value.empty?
                propstring = sprintf "%s:%s", name, value.join(" ")
                sanitized_node = Crass.parse_properties(propstring).first
                sanitized_tree << sanitized_node << CRASS_SEMICOLON
              end
            end
          end

          Crass::Parser.stringify sanitized_tree
        end

        #
        #  libxml2 >= 2.9.2 fails to escape comments within some attributes.
        #
        #  see comments about CVE-2018-8048 within the tests for more information
        #
        def force_correct_attribute_escaping! node
          return unless Nokogiri::VersionInfo.instance.libxml2?

          node.attribute_nodes.each do |attr_node|
            next unless LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES.include?(attr_node.name)

            tag_name = LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES_QUALIFYING_TAG[attr_node.name]
            next unless tag_name.nil? || tag_name == node.name

            #
            #  this block is just like CGI.escape in Ruby 2.4, but
            #  only encodes space and double-quote, to mimic
            #  pre-2.9.2 behavior
            #
            encoding = attr_node.value.encoding
            attr_node.value = attr_node.value.gsub(/[ "]/) do |m|
              '%' + m.unpack('H2' * m.bytesize).join('%').upcase
            end.force_encoding(encoding)
          end
        end

      end
    end
  end
end
