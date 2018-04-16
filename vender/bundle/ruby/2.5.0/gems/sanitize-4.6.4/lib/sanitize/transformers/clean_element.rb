# encoding: utf-8

require 'set'

class Sanitize; module Transformers; class CleanElement

  # Matches a valid HTML5 data attribute name. The unicode ranges included here
  # are a conservative subset of the full range of characters that are
  # technically allowed, with the intent of matching the most common characters
  # used in data attribute names while excluding uncommon or potentially
  # misleading characters, or characters with the potential to be normalized
  # into unsafe or confusing forms.
  #
  # If you need data attr names with characters that aren't included here (such
  # as combining marks, full-width characters, or CJK), please consider creating
  # a custom transformer to validate attributes according to your needs.
  #
  # http://www.whatwg.org/specs/web-apps/current-work/multipage/elements.html#embedding-custom-non-visible-data-with-the-data-*-attributes
  REGEX_DATA_ATTR = /\Adata-(?!xml)[a-z_][\w.\u00E0-\u00F6\u00F8-\u017F\u01DD-\u02AF-]*\z/u

  # Attributes that need additional escaping on `<a>` elements due to unsafe
  # libxml2 behavior.
  UNSAFE_LIBXML_ATTRS_A = Set.new(%w[
    name
  ])

  # Attributes that need additional escaping on all elements due to unsafe
  # libxml2 behavior.
  UNSAFE_LIBXML_ATTRS_GLOBAL = Set.new(%w[
    action
    href
    src
  ])

  # Mapping of original characters to escape sequences for characters that
  # should be escaped in attributes affected by unsafe libxml2 behavior.
  UNSAFE_LIBXML_ESCAPE_CHARS = {
    ' ' => '%20',
    '"' => '%22'
  }

  # Regex that matches any single character that needs to be escaped in
  # attributes affected by unsafe libxml2 behavior.
  UNSAFE_LIBXML_ESCAPE_REGEX = /[ "]/

  def initialize(config)
    @add_attributes          = config[:add_attributes]
    @attributes              = config[:attributes].dup
    @elements                = config[:elements]
    @protocols               = config[:protocols]
    @remove_all_contents     = false
    @remove_element_contents = Set.new
    @whitespace_elements     = {}

    @attributes.each do |element_name, attrs|
      unless element_name == :all
        @attributes[element_name] = Set.new(attrs).merge(@attributes[:all] || [])
      end
    end

    # Backcompat: if :whitespace_elements is a Set, convert it to a hash.
    if config[:whitespace_elements].is_a?(Set)
      config[:whitespace_elements].each do |element|
        @whitespace_elements[element] = {:before => ' ', :after => ' '}
      end
    else
      @whitespace_elements = config[:whitespace_elements]
    end

    if config[:remove_contents].is_a?(Set)
      @remove_element_contents.merge(config[:remove_contents].map(&:to_s))
    else
      @remove_all_contents = !!config[:remove_contents]
    end
  end

  def call(env)
    node = env[:node]
    return if node.type != Nokogiri::XML::Node::ELEMENT_NODE || env[:is_whitelisted]

    name = env[:node_name]

    # Delete any element that isn't in the config whitelist, unless the node has
    # already been deleted from the document.
    #
    # It's important that we not try to reparent the children of a node that has
    # already been deleted, since that seems to trigger a memory leak in
    # Nokogiri.
    unless @elements.include?(name) || node.parent.nil?
      # Elements like br, div, p, etc. need to be replaced with whitespace in
      # order to preserve readability.
      if @whitespace_elements.include?(name)
        node.add_previous_sibling(Nokogiri::XML::Text.new(@whitespace_elements[name][:before].to_s, node.document))

        unless node.children.empty?
          node.add_next_sibling(Nokogiri::XML::Text.new(@whitespace_elements[name][:after].to_s, node.document))
        end
      end

      unless @remove_all_contents || @remove_element_contents.include?(name)
        node.add_previous_sibling(node.children)
      end

      node.unlink
      return
    end

    attr_whitelist = @attributes[name] || @attributes[:all]

    if attr_whitelist.nil?
      # Delete all attributes from elements with no whitelisted attributes.
      node.attribute_nodes.each {|attr| attr.unlink }
    else
      allow_data_attributes = attr_whitelist.include?(:data)

      # Delete any attribute that isn't allowed on this element.
      node.attribute_nodes.each do |attr|
        attr_name = attr.name.downcase

        unless attr_whitelist.include?(attr_name)
          # The attribute isn't whitelisted.

          if allow_data_attributes && attr_name.start_with?('data-')
            # Arbitrary data attributes are allowed. If this is a data
            # attribute, continue.
            next if attr_name =~ REGEX_DATA_ATTR
          end

          # Either the attribute isn't a data attribute or arbitrary data
          # attributes aren't allowed. Remove the attribute.
          attr.unlink
          next
        end

        # The attribute is whitelisted.

        # Remove any attributes that use unacceptable protocols.
        if @protocols.include?(name) && @protocols[name].include?(attr_name)
          attr_protocols = @protocols[name][attr_name]

          if attr.value =~ REGEX_PROTOCOL
            unless attr_protocols.include?($1.downcase)
              attr.unlink
              next
            end

          else
            unless attr_protocols.include?(:relative)
              attr.unlink
              next
            end
          end

          # Leading and trailing whitespace around URLs is ignored at parse
          # time. Stripping it here prevents it from being escaped by the
          # libxml2 workaround below.
          attr.value = attr.value.strip
        end

        # libxml2 >= 2.9.2 doesn't escape comments within some attributes, in an
        # attempt to preserve server-side includes. This can result in XSS since
        # an unescaped double quote can allow an attacker to inject a
        # non-whitelisted attribute.
        #
        # Sanitize works around this by implementing its own escaping for
        # affected attributes, some of which can exist on any element and some
        # of which can only exist on `<a>` elements.
        #
        # The relevant libxml2 code is here:
        # <https://github.com/GNOME/libxml2/commit/960f0e275616cadc29671a218d7fb9b69eb35588>
        if UNSAFE_LIBXML_ATTRS_GLOBAL.include?(attr_name) ||
            (name == 'a' && UNSAFE_LIBXML_ATTRS_A.include?(attr_name))

          attr.value = attr.value.gsub(UNSAFE_LIBXML_ESCAPE_REGEX, UNSAFE_LIBXML_ESCAPE_CHARS)
        end
      end
    end

    # Add required attributes.
    if @add_attributes.include?(name)
      @add_attributes[name].each {|key, val| node[key] = val }
    end
  end

end; end; end
