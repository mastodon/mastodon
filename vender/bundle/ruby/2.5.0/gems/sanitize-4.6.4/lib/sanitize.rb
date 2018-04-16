# encoding: utf-8

require 'nokogumbo'
require 'set'

require_relative 'sanitize/version'
require_relative 'sanitize/config'
require_relative 'sanitize/config/default'
require_relative 'sanitize/config/restricted'
require_relative 'sanitize/config/basic'
require_relative 'sanitize/config/relaxed'
require_relative 'sanitize/css'
require_relative 'sanitize/transformers/clean_cdata'
require_relative 'sanitize/transformers/clean_comment'
require_relative 'sanitize/transformers/clean_css'
require_relative 'sanitize/transformers/clean_doctype'
require_relative 'sanitize/transformers/clean_element'

class Sanitize
  attr_reader :config

  # Matches an attribute value that could be treated by a browser as a URL
  # with a protocol prefix, such as "http:" or "javascript:". Any string of zero
  # or more characters followed by a colon is considered a match, even if the
  # colon is encoded as an entity and even if it's an incomplete entity (which
  # IE6 and Opera will still parse).
  REGEX_PROTOCOL = /\A\s*([^\/#]*?)(?:\:|&#0*58|&#x0*3a)/i

  # Matches Unicode characters that should be stripped from HTML before passing
  # it to the parser.
  #
  # http://www.w3.org/TR/unicode-xml/#Charlist
  REGEX_UNSUITABLE_CHARS = /[\u0000\u0340\u0341\u17a3\u17d3\u2028\u2029\u202a-\u202e\u206a-\u206f\ufff9-\ufffb\ufeff\ufffc\u{1d173}-\u{1d17a}\u{e0000}-\u{e007f}]/u

  #--
  # Class Methods
  #++

  # Returns a sanitized copy of the given full _html_ document, using the
  # settings in _config_ if specified.
  #
  # When sanitizing a document, the `<html>` element must be whitelisted or an
  # error will be raised. If this is undesirable, you should probably use
  # {#fragment} instead.
  def self.document(html, config = {})
    Sanitize.new(config).document(html)
  end

  # Returns a sanitized copy of the given _html_ fragment, using the settings in
  # _config_ if specified.
  def self.fragment(html, config = {})
    Sanitize.new(config).fragment(html)
  end

  # Sanitizes the given `Nokogiri::XML::Node` instance and all its children.
  def self.node!(node, config = {})
    Sanitize.new(config).node!(node)
  end

  # Aliases for pre-3.0.0 backcompat.
  class << Sanitize
    # @deprecated Use {.document} instead.
    alias_method :clean_document, :document

    # @deprecated Use {.fragment} instead.
    alias_method :clean, :fragment

    # @deprecated Use {.node!} instead.
    alias_method :clean_node!, :node!
  end

  #--
  # Instance Methods
  #++

  # Returns a new Sanitize object initialized with the settings in _config_.
  def initialize(config = {})
    @config = Config.merge(Config::DEFAULT, config)

    @transformers = Array(@config[:transformers]).dup

    # Default transformers always run at the end of the chain, after any custom
    # transformers.
    @transformers << Transformers::CleanComment unless @config[:allow_comments]

    if @config[:elements].include?('style')
      scss = Sanitize::CSS.new(config)
      @transformers << Transformers::CSS::CleanElement.new(scss)
    end

    if @config[:attributes].values.any? {|attr| attr.include?('style') }
      scss ||= Sanitize::CSS.new(config)
      @transformers << Transformers::CSS::CleanAttribute.new(scss)
    end

    @transformers <<
        Transformers::CleanDoctype <<
        Transformers::CleanCDATA <<
        Transformers::CleanElement.new(@config)
  end

  # Returns a sanitized copy of the given _html_ document.
  #
  # When sanitizing a document, the `<html>` element must be whitelisted or an
  # error will be raised. If this is undesirable, you should probably use
  # {#fragment} instead.
  def document(html)
    return '' unless html

    doc = Nokogiri::HTML5.parse(preprocess(html))
    node!(doc)
    to_html(doc)
  end

  # @deprecated Use {#document} instead.
  alias_method :clean_document, :document

  # Returns a sanitized copy of the given _html_ fragment.
  def fragment(html)
    return '' unless html

    html = preprocess(html)
    doc  = Nokogiri::HTML5.parse("<html><body>#{html}")

    # Hack to allow fragments containing <body>. Borrowed from
    # Nokogiri::HTML::DocumentFragment.
    if html =~ /\A<body(?:\s|>)/i
      path = '/html/body'
    else
      path = '/html/body/node()'
    end

    frag = doc.fragment
    frag << doc.xpath(path)

    node!(frag)
    to_html(frag)
  end

  # @deprecated Use {#fragment} instead.
  alias_method :clean, :fragment

  # Sanitizes the given `Nokogiri::XML::Node` and all its children, modifying it
  # in place.
  #
  # If _node_ is a `Nokogiri::XML::Document`, the `<html>` element must be
  # whitelisted or an error will be raised.
  def node!(node)
    raise ArgumentError unless node.is_a?(Nokogiri::XML::Node)

    if node.is_a?(Nokogiri::XML::Document)
      unless @config[:elements].include?('html')
        raise Error, 'When sanitizing a document, "<html>" must be whitelisted.'
      end
    end

    node_whitelist = Set.new

    traverse(node) do |n|
      transform_node!(n, node_whitelist)
    end

    node
  end

  # @deprecated Use {#node!} instead.
  alias_method :clean_node!, :node!

  private

  # Preprocesses HTML before parsing to remove undesirable Unicode chars.
  def preprocess(html)
    html = html.to_s.dup

    unless html.encoding.name == 'UTF-8'
      html.encode!('UTF-8',
        :invalid => :replace,
        :undef   => :replace)
    end

    html.gsub!(REGEX_UNSUITABLE_CHARS, '')
    html
  end

  def to_html(node)
    replace_meta = false

    # Hacky workaround for a libxml2 bug that adds an undesired Content-Type
    # meta tag to all serialized HTML documents.
    #
    # https://github.com/sparklemotion/nokogiri/issues/1008
    if node.type == Nokogiri::XML::Node::DOCUMENT_NODE ||
        node.type == Nokogiri::XML::Node::HTML_DOCUMENT_NODE

      regex_meta   = %r|(<html[^>]*>\s*<head[^>]*>\s*)<meta http-equiv="Content-Type" content="text/html; charset=utf-8">|i

      # Only replace the content-type meta tag if <meta> isn't whitelisted or
      # the original document didn't actually include a content-type meta tag.
      replace_meta = !@config[:elements].include?('meta') ||
        node.xpath('/html/head/meta[@http-equiv]').none? do |meta|
          meta['http-equiv'].casecmp('content-type').zero?
        end
    end

    so = Nokogiri::XML::Node::SaveOptions

    # Serialize to HTML without any formatting to prevent Nokogiri from adding
    # newlines after certain tags.
    html = node.to_html(
      :encoding  => 'utf-8',
      :indent    => 0,
      :save_with => so::NO_DECLARATION | so::NO_EMPTY_TAGS | so::AS_HTML
    )

    html.gsub!(regex_meta, '\1') if replace_meta
    html
  end

  def transform_node!(node, node_whitelist)
    @transformers.each do |transformer|
      result = transformer.call(
        :config         => @config,
        :is_whitelisted => node_whitelist.include?(node),
        :node           => node,
        :node_name      => node.name.downcase,
        :node_whitelist => node_whitelist
      )

      if result.is_a?(Hash) && result[:node_whitelist].respond_to?(:each)
        node_whitelist.merge(result[:node_whitelist])
      end
    end

    node
  end

  # Performs top-down traversal of the given node, operating first on the node
  # itself, then traversing each child (if any) in order.
  def traverse(node, &block)
    yield node

    child = node.child

    while child do
      prev = child.previous_sibling
      traverse(child, &block)

      if child.parent == node
        child = child.next_sibling
      else
        # The child was unlinked or reparented, so traverse the previous node's
        # next sibling, or the parent's first child if there is no previous
        # node.
        child = prev ? prev.next_sibling : node.child
      end
    end
  end

  class Error < StandardError; end
end
