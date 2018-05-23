require 'link_header/version'
require 'strscan'

#
# Represents an HTTP link header of the form described in the draft spec http://tools.ietf.org/id/draft-nottingham-http-link-header-06.txt.
# It is simply a list of LinkHeader::Link objects and some conversion functions.
#
class LinkHeader
  # An array of Link objects
  attr_reader :links
  
  #
  # Initialize from a collection of either LinkHeader::Link objects or data from which Link objects can be created.
  #
  # From a list of LinkHeader::Link objects:
  #
  #   LinkHeader.new([
  #     LinkHeader::Link.new("http://example.com/foo", [["rel", "self"]]),
  #     LinkHeader::Link.new("http://example.com/",    [["rel", "up"]])])
  #
  # From the equivalent JSON-friendly raw data:
  #
  #   LinkHeader.new([
  #     ["http://example.com/foo", [["rel", "self"]]],
  #     ["http://example.com/",    [["rel", "up"]]]]).to_s
  #
  # See also LinkHeader.parse
  #
  def initialize(links=[])
    if links
      @links = links.map{|l| l.kind_of?(Link) ? l : Link.new(*l)}
    else
      @links = []
    end
  end
  
  def <<(link)
    link = link.kind_of?(Link) ? link : Link.new(*link)
    @links << link
  end
  
  #
  # Convert to a JSON-friendly array
  #
  #   LinkHeader.parse('<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"').to_a
  #   #=> [["http://example.com/foo", [["rel", "self"]]],
  #        ["http://example.com/", [["rel", "up"]]]]
  #
  def to_a
    links.map{|l| l.to_a}
  end
  
  #
  # Convert to string representation as per the link header spec
  #
  #   LinkHeader.new([
  #     ["http://example.com/foo", [["rel", "self"]]],
  #     ["http://example.com/",    [["rel", "up"]]]]).to_s
  #   #=> '<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"'
  #
  def to_s
    links.join(', ')
  end
  
  #
  # Regexes for link header parsing.  TOKEN and QUOTED in particular should conform to RFC2616.
  #
  # Acknowledgement: The QUOTED regexp is based on
  # http://stackoverflow.com/questions/249791/regexp-for-quoted-string-with-escaping-quotes/249937#249937
  #
  HREF   = / *< *([^>]*) *> *;? */                  #:nodoc: note: no attempt to check URI validity
  TOKEN  = /([^()<>@,;:\"\[\]?={}\s]+)/             #:nodoc: non-empty sequence of non-separator characters
  QUOTED = /"((?:[^"\\]|\\.)*)"/                    #:nodoc: double-quoted strings with backslash-escaped double quotes
  ATTR   = /#{TOKEN} *= *(#{TOKEN}|#{QUOTED}) */    #:nodoc:
  SEMI   = /; */                                    #:nodoc:
  COMMA  = /, */                                    #:nodoc:

  #
  # Parse a link header, returning a new LinkHeader object
  #
  #   LinkHeader.parse('<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"').to_a
  #   #=> [["http://example.com/foo", [["rel", "self"]]],
  #        ["http://example.com/", [["rel", "up"]]]]
  #
  def self.parse(link_header)
    return new unless link_header
    
    scanner = StringScanner.new(link_header)
    links = []
    while scanner.scan(HREF)
      href = scanner[1]
      attrs = []
      while scanner.scan(ATTR)
        attr_name, token, quoted = scanner[1], scanner[3], scanner[4]
        attrs.push([attr_name, token || quoted.gsub(/\\"/, '"')])
        break unless scanner.scan(SEMI)
      end
      links.push(Link.new(href, attrs))
      break unless scanner.scan(COMMA)
    end

    new(links)
  end
  
  #
  # Find a member link that has the given attributes
  #
  def find_link(*attr_pairs)
    links.detect do |link|
      !attr_pairs.detect do |pair|
        !link.attr_pairs.include?(pair)
      end
    end 
  end
  
  #
  # Render as a list of HTML link elements
  #
  def to_html(separator="\n")
    links.map{|link| link.to_html}.join(separator)
  end

  #
  # Represents a link - an href and a list of attributes (key value pairs)
  #
  #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"]]).to_s
  #   => '<http://example.com/foo>; rel="self"'
  #
  class Link
    #
    # The link's URI string
    #
    #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"]]).href
    #   => 'http://example.com/foo>'
    #
    attr_reader :href
    
    #
    # The link's attributes, an array of key-value pairs
    #
    #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"], ["rel", "canonical"]]).attr_pairs
    #   => [["rel", "self"], ["rel", "canonical"]]
    #
    attr_reader :attr_pairs
    
    #
    # Initialize a Link from an href and attribute list
    #
    #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"]]).to_s
    #   => '<http://example.com/foo>; rel="self"'
    #
    def initialize(href, attr_pairs)
      @href, @attr_pairs = href, attr_pairs
    end
    
    #
    # Lazily convert the attribute list to a Hash
    #
    # Beware repeated attribute names (it's safer to use #attr_pairs if this is risk):
    #
    #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"], ["rel", "canonical"]]).attrs
    #   => {"rel" =>"canonical"}
    #
    def attrs
      @attrs ||= Hash[*attr_pairs.flatten]
    end
    
    #
    # Access #attrs by key
    #
    def [](key)
      attrs[key]
    end
    
    #
    # Convert to a JSON-friendly Array
    #
    #   LinkHeader::Link.new("http://example.com/foo", [["rel", "self"], ["rel", "canonical"]]).to_a
    #   => ["http://example.com/foo", [["rel", "self"], ["rel", "canonical"]]]
    #
    def to_a
      [href, attr_pairs]
    end
    
    #
    # Convert to string representation as per the link header spec.  This includes backspace-escaping doublequote characters in
    # quoted attribute values.
    #
    # Convert to string representation as per the link header spec
    #
    #   LinkHeader::Link.new(["http://example.com/foo", [["rel", "self"]]]).to_s
    #   #=> '<http://example.com/foo>; rel="self"'
    #
    def to_s
      (["<#{href}>"] + attr_pairs.map{|k, v| "#{k}=\"#{v.gsub(/"/, '\"')}\""}).join('; ')
    end
    
    #
    # Bonus!  Render as an HTML link element
    #
    #   LinkHeader::Link.new(["http://example.com/foo", [["rel", "self"]]]).to_html
    #   #=> '<link href="http://example.com/foo" rel="self">'
    def to_html
      ([%Q(<link href="#{href}")] + attr_pairs.map{|k, v| "#{k}=\"#{v.gsub(/"/, '\"')}\""}).join(' ') + '>'
    end
  end
end
