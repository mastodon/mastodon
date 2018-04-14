module Loofah
  #
  #  A RuntimeError raised when Loofah could not find an appropriate scrubber.
  #
  class ScrubberNotFound < RuntimeError ; end

  #
  #  A Scrubber wraps up a block (or method) that is run on an HTML node (element):
  #
  #    # change all <span> tags to <div> tags
  #    span2div = Loofah::Scrubber.new do |node|
  #      node.name = "div" if node.name == "span"
  #    end
  #
  #  Alternatively, this scrubber could have been implemented as:
  #
  #    class Span2Div < Loofah::Scrubber
  #      def scrub(node)
  #        node.name = "div" if node.name == "span"
  #      end
  #    end
  #    span2div = Span2Div.new
  #
  #  This can then be run on a document:
  #
  #    Loofah.fragment("<span>foo</span><p>bar</p>").scrub!(span2div).to_s
  #    # => "<div>foo</div><p>bar</p>"
  #
  #  Scrubbers can be run on a document in either a top-down traversal (the
  #  default) or bottom-up. Top-down scrubbers can optionally return
  #  Scrubber::STOP to terminate the traversal of a subtree.
  #
  class Scrubber

    # Top-down Scrubbers may return CONTINUE to indicate that the subtree should be traversed.
    CONTINUE = Object.new.freeze

    # Top-down Scrubbers may return STOP to indicate that the subtree should not be traversed.
    STOP     = Object.new.freeze

    # When a scrubber is initialized, the :direction may be specified
    # as :top_down (the default) or :bottom_up.
    attr_reader :direction

    # When a scrubber is initialized, the optional block is saved as
    # :block. Note that, if no block is passed, then the +scrub+
    # method is assumed to have been implemented.
    attr_reader :block

    #
    #  Options may include
    #    :direction => :top_down (the default)
    #  or
    #    :direction => :bottom_up
    #
    #  For top_down traversals, if the block returns
    #  Loofah::Scrubber::STOP, then the traversal will be terminated
    #  for the current node's subtree.
    #
    #  Alternatively, a Scrubber may inherit from Loofah::Scrubber,
    #  and implement +scrub+, which is slightly faster than using a
    #  block.
    #
    def initialize(options = {}, &block)
      direction = options[:direction] || :top_down
      unless [:top_down, :bottom_up].include?(direction)
        raise ArgumentError, "direction #{direction} must be one of :top_down or :bottom_up" 
      end
      @direction, @block = direction, block
    end

    #
    #  Calling +traverse+ will cause the document to be traversed by
    #  either the lambda passed to the initializer or the +scrub+
    #  method, in the direction specified at +new+ time.
    #
    def traverse(node)
      direction == :bottom_up ? traverse_conditionally_bottom_up(node) : traverse_conditionally_top_down(node)
    end

    #
    #  When +new+ is not passed a block, the class may implement
    #  +scrub+, which will be called for each document node.
    #
    def scrub(node)
      raise ScrubberNotFound, "No scrub method has been defined on #{self.class.to_s}"
    end

    #
    # If the attribute is not set, add it
    # If the attribute is set, don't overwrite the existing value
    #
    def append_attribute(node, attribute, value)
      current_value = node.get_attribute(attribute) || ''
      current_values = current_value.split(/\s+/)
      updated_value = current_values | [value]
      node.set_attribute(attribute, updated_value.join(' '))
    end

    private

    def html5lib_sanitize(node)
      case node.type
      when Nokogiri::XML::Node::ELEMENT_NODE
        if HTML5::Scrub.allowed_element? node.name
          HTML5::Scrub.scrub_attributes node
          return Scrubber::CONTINUE
        end
      when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
        return Scrubber::CONTINUE
      end
      Scrubber::STOP
    end

    def traverse_conditionally_top_down(node)
      if block
        return if block.call(node) == STOP
      else
        return if scrub(node) == STOP
      end
      node.children.each {|j| traverse_conditionally_top_down(j)}
    end

    def traverse_conditionally_bottom_up(node)
      node.children.each {|j| traverse_conditionally_bottom_up(j)}
      if block
        block.call(node)
      else
        scrub(node)
      end
    end
  end
end
