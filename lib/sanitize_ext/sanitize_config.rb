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

    # We remove all "style" attributes. In particular we remove all color
    # attributes and length percentages.
    COMMON_MATH_ATTRS = %w(
      dir
      displaystyle
      mathvariant
      scriptlevel
    )
    MATH_TAG_ATTRS = {
      'annotation' => %w(encoding),
      'annotation-xml' => %w(encoding),
      # we remove all attributes from maction
      'maction' => %w(),
      'math' => %w(display alttext),
      'merror' => %w(),
      # see below
      'mfrac' => %w(linethickness),
      'mi' => %w(),
      'mmultiscripts' => %w(),
      'mn' => %w(),
      'mo' => %w(
        form
        fence
        separator
        stretchy
        symmetric
        largeop
        movablelimits
      ),
      'mover' => %w(accent),
      'moverunder' => %w(accent accentunder),
      # see <mspace>
      'mpadded' => %w(),
      'mphantom' => %w(),
      'mprescripts' => %w(),
      'mroot' => %w(),
      'mrow' => %w(),
      'ms' => %w(),
      # mspace is only described by its `width`, `depth` and `height` attributes.
      # If these are removed, perhaps we should remove the element in general?
      'mspace' => %w(),
      'msqrt' => %w(),
      'mstyle' => %w(),
      'msub' => %w(),
      'msubsup' => %w(),
      'msup' => %w(),
      'mtable' => %w(),
      'mtd' => %w(colspan rowspan),
      'mtext' => %w(),
      'mtr' => %w(),
      'munder' => %w(accentunder),
      'semantics' => %w(),
    }.transform_values { |attr_list| attr_list + COMMON_MATH_ATTRS }.freeze

    # We need some special logic for some math tags.
    #
    # In particular, <mathfrac> contains a (usually stylistic) attribute
    # `linethickness`, which denotes the thickness of the horizontal bar.
    # However, `linethickness="0"`, erases the horizontal bar completely. This
    # looks more like a two-element table, and could denote a two-element
    # vector, or (in the MathML Core spec) the binomial coefficient!
    # For example:
    #   <mo>(</mo><mfrac linethickness="0"><mi>x</mi><mi>y</mi></mfrac><mo>)</mo>
    # denotes xCy, while
    #   <mo>(</mo><mfrac><mi>x</mi><mi>y</mi></mfrac><mo>)</mo>
    # denotes (x/y). These two constructions are very different and the
    # distinction needs to be mantained.
    MATH_TRANSFORMER = lambda do |env|
      node = env[:node]
      return if env[:is_allowlisted] || !node.element?
      return unless env[:node_name] == 'mfrac'

      node.attribute_nodes.each do |attr|
        attr.unlink if attr.name == 'linethickness' && attr.value != '0'
      end
      # we don't allowlist the node. instead we let the CleanElement transformer
      # take care of the rest of the attributes.
    end

    CLASS_WHITELIST_TRANSFORMER = lambda do |env|
      node = env[:node]
      class_list = node['class']&.split(/[\t\n\f\r ]/)

      return unless class_list

      class_list.keep_if do |e|
        next true if /^(h|p|u|dt|e)-/.match?(e) # microformats classes
        next true if /^(mention|hashtag)$/.match?(e) # semantic classes
        next true if /^(ellipsis|invisible)$/.match?(e) # link formatting classes
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
      return unless %w(h1 h2 h3 h4 h5 h6 blockquote pre ul ol li).include?(env[:node_name])

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
      elements: %w(p br span a) + MATH_TAG_ATTRS.keys,

      attributes: {
        'a'    => %w(href rel class),
        'span' => %w(class),
      }.merge(MATH_TAG_ATTRS),

      add_attributes: {
        'a' => {
          'rel' => 'nofollow noopener noreferrer',
          'target' => '_blank',
        },
      },

      protocols: {},

      transformers: [
        CLASS_WHITELIST_TRANSFORMER,
        UNSUPPORTED_ELEMENTS_TRANSFORMER,
        UNSUPPORTED_HREF_TRANSFORMER,
        MATH_TRANSFORMER,
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
