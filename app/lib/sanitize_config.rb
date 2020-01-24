# frozen_string_literal: true

class Sanitize
  module Config
    HTTP_PROTOCOLS ||= ['http', 'https', 'dat', 'dweb', 'ipfs', 'ipns', 'ssb', 'gopher', 'xmpp', 'magnet', :relative].freeze

    CLASS_WHITELIST_TRANSFORMER = lambda do |env|
      node = env[:node]
      class_list = node['class']&.split(/[\t\n\f\r ]/)

      return unless class_list

      class_list.keep_if do |e|
        next true if e =~ /^(h|p|u|dt|e)-/ # microformats classes
        next true if e =~ /^(mention|hashtag)$/ # semantic classes
        next true if e =~ /^(ellipsis|invisible)$/ # link formatting classes
      end

      node['class'] = class_list.join(' ')
    end

    IMG_TAG_TRANSFORMER = lambda do |env|
      node = env[:node]

      return unless env[:node_name] == 'img'

      node.name = 'a'

      node['href'] = node['src']
      if node['alt'].present?
        node.content = "[🖼  #{node['alt']}]"
      else
        url = node['href']
        prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
        text   = url[prefix.length, 30]
        text   = text + "…" if url[prefix.length..-1].length > 30
        node.content = "[🖼  #{text}]"
      end
    end

    MASTODON_STRICT ||= freeze_config(
      elements: %w(p br span a abbr del pre blockquote code b strong u sub sup i em h1 h2 h3 h4 h5 ul ol li),

      attributes: {
        'a'          => %w(href rel class title),
        'span'       => %w(class),
        'abbr'       => %w(title),
        'blockquote' => %w(cite),
      },

      add_attributes: {
        'a' => {
          'rel' => 'nofollow noopener tag noreferrer',
          'target' => '_blank',
        },
      },

      protocols: {
        'a'          => { 'href' => HTTP_PROTOCOLS },
        'blockquote' => { 'cite' => HTTP_PROTOCOLS },
      },

      transformers: [
        CLASS_WHITELIST_TRANSFORMER,
        IMG_TAG_TRANSFORMER,
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
