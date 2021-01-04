# frozen_string_literal: true

class Sanitize
  module Config
    HTTP_PROTOCOLS = %w(
      http
      https
    ).freeze

    LINK_PROTOCOLS = %w(
      http
      https
      dat
      dweb
      ipfs
      ipns
      ssb
      gopher
      xmpp
      magnet
      gemini
    ).freeze

    CLASS_WHITELIST_TRANSFORMER = lambda do |env|
      node = env[:node]
      class_list = node['class']&.split(/[\t\n\f\r ]/)

      return unless class_list

      class_list.keep_if do |e|
        next true if /^(h|p|u|dt|e)-/.match?(e) # microformats classes
        next true if /^(mention|hashtag)$/.match?(e) # semantic classes
        next true if /^(ellipsis|invisible)$/.match?(e) # link formatting classes
        next true if /^quote-inline$/.match?(e) # quote inline classes
        next true if /(ge|gs|o|ow|c|cm|cp|c1|cs|n|py|nl|ni|nb|bp|nf|na|nx|nc|nn|no|ne|nd|nt|kn|k|kc|kd|kp|kr|kt|nv|vg|vc|vi|m|il|mf|mh|mi|mo|s|sr|s2|sb|sh|sx|s1|ss|se|si|sc|sd|l|ld|p|w|err|gp|gi|gd|gh|gu|hll|lineno|highlight)/.match?(e) # ruby-rouge classes
      end

      node['class'] = class_list.join(' ')
    end

    UNSUPPORTED_HREF_TRANSFORMER = lambda do |env|
      return unless env[:node_name] == 'a'

      current_node = env[:node]

      scheme = begin
        if current_node['href'] =~ Sanitize::REGEX_PROTOCOL
          Regexp.last_match(1).downcase
        else
          :relative
        end
      end

      current_node.replace(current_node.text) unless LINK_PROTOCOLS.include?(scheme)
    end

    UNSUPPORTED_ELEMENTS_TRANSFORMER = lambda do |env|
      return unless %w(h1 h2 h3 h4 h5 h6 ul ol li).include?(env[:node_name])

      current_node = env[:node]

      case env[:node_name]
      when 'li'
        current_node.traverse do |node|
          next unless %w(p ul ol li).include?(node.name)

          node.add_next_sibling('<br>') if node.next_sibling
          node.replace(node.children) unless node.text?
        end
      else
        current_node.name = 'p'
      end
    end

    MASTODON_STRICT ||= freeze_config(
      elements: %w(p br span a em i  strong b code del s blockquote pre code),

      attributes: {
        'a'    => %w(href rel class),
        'span' => %w(class),
      },

      add_attributes: {
        'a' => {
          'rel' => 'nofollow noopener noreferrer',
          'target' => '_blank',
        },
        'pre' => {
          'class' => 'highlight'
        }
      },

      protocols: {},

      transformers: [
        CLASS_WHITELIST_TRANSFORMER,
        UNSUPPORTED_ELEMENTS_TRANSFORMER,
        UNSUPPORTED_HREF_TRANSFORMER,
      ]
    )

    MASTODON_OEMBED ||= freeze_config merge(
      RELAXED,
      elements: RELAXED[:elements] + %w(audio embed iframe source video),

      attributes: merge(
        RELAXED[:attributes],
        'audio'  => %w(controls),
        'embed'  => %w(height src type width),
        'iframe' => %w(allowfullscreen frameborder height scrolling src width),
        'source' => %w(src type),
        'video'  => %w(controls height loop width),
        'div'    => [:data]
      ),

      protocols: merge(
        RELAXED[:protocols],
        'embed'  => { 'src' => HTTP_PROTOCOLS },
        'iframe' => { 'src' => HTTP_PROTOCOLS },
        'source' => { 'src' => HTTP_PROTOCOLS }
      )
    )
  end
end
