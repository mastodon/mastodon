module Loofah
  #
  #  Mixes +scrub!+ into Document, DocumentFragment, Node and NodeSet.
  #
  #  Traverse the document or fragment, invoking the +scrubber+ on
  #  each node.
  #
  #  +scrubber+ must either be one of the symbols representing the
  #  built-in scrubbers (see Scrubbers), or a Scrubber instance.
  #
  #    span2div = Loofah::Scrubber.new do |node|
  #      node.name = "div" if node.name == "span"
  #    end
  #    Loofah.fragment("<span>foo</span><p>bar</p>").scrub!(span2div).to_s
  #    # => "<div>foo</div><p>bar</p>"
  #
  #  or
  #
  #    unsafe_html = "ohai! <div>div is safe</div> <script>but script is not</script>"
  #    Loofah.fragment(unsafe_html).scrub!(:strip).to_s
  #    # => "ohai! <div>div is safe</div> "
  #
  #  Note that this method is called implicitly from
  #  Loofah.scrub_fragment and Loofah.scrub_document.
  #
  #  Please see Scrubber for more information on implementation and traversal, and
  #  README.rdoc for more example usage.
  #
  module ScrubBehavior
    module Node # :nodoc:
      def scrub!(scrubber)
        #
        #  yes. this should be three separate methods. but nokogiri
        #  decorates (or not) based on whether the module name has
        #  already been included. and since documents get decorated
        #  just like their constituent nodes, we need to jam all the
        #  logic into a single module.
        #
        scrubber = ScrubBehavior.resolve_scrubber(scrubber)
        case self
        when Nokogiri::XML::Document
          scrubber.traverse(root) if root
        when Nokogiri::XML::DocumentFragment
          children.scrub! scrubber
        else
          scrubber.traverse(self)
        end
        self
      end
    end

    module NodeSet # :nodoc:
      def scrub!(scrubber)
        each { |node| node.scrub!(scrubber) }
        self
      end
    end

    def ScrubBehavior.resolve_scrubber(scrubber) # :nodoc:
      scrubber = Scrubbers::MAP[scrubber].new if Scrubbers::MAP[scrubber]
      unless scrubber.is_a?(Loofah::Scrubber)
        raise Loofah::ScrubberNotFound, "not a Scrubber or a scrubber name: #{scrubber.inspect}"
      end
      scrubber
    end
  end

  #
  #  Overrides +text+ in HTML::Document and HTML::DocumentFragment,
  #  and mixes in +to_text+.
  #
  module TextBehavior
    #
    #  Returns a plain-text version of the markup contained by the document,
    #  with HTML entities encoded.
    #
    #  This method is significantly faster than #to_text, but isn't
    #  clever about whitespace around block elements.
    #
    #    Loofah.document("<h1>Title</h1><div>Content</div>").text
    #    # => "TitleContent"
    #
    #  By default, the returned text will have HTML entities
    #  escaped. If you want unescaped entities, and you understand
    #  that the result is unsafe to render in a browser, then you
    #  can pass an argument as shown:
    #
    #    frag = Loofah.fragment("&lt;script&gt;alert('EVIL');&lt;/script&gt;")
    #    # ok for browser:
    #    frag.text                                 # => "&lt;script&gt;alert('EVIL');&lt;/script&gt;"
    #    # decidedly not ok for browser:
    #    frag.text(:encode_special_chars => false) # => "<script>alert('EVIL');</script>"
    #
    def text(options={})
      result = serialize_root.children.inner_text rescue ""
      if options[:encode_special_chars] == false
        result # possibly dangerous if rendered in a browser
      else
        encode_special_chars result
      end
    end
    alias :inner_text :text
    alias :to_str     :text

    #
    #  Returns a plain-text version of the markup contained by the
    #  fragment, with HTML entities encoded.
    #
    #  This method is slower than #to_text, but is clever about
    #  whitespace around block elements.
    #
    #    Loofah.document("<h1>Title</h1><div>Content</div>").to_text
    #    # => "\nTitle\n\nContent\n"
    #
    def to_text(options={})
      Loofah.remove_extraneous_whitespace self.dup.scrub!(:newline_block_elements).text(options)
    end
  end

  module DocumentDecorator # :nodoc:
    def initialize(*args, &block)
      super
      self.decorators(Nokogiri::XML::Node) << ScrubBehavior::Node
      self.decorators(Nokogiri::XML::NodeSet) << ScrubBehavior::NodeSet
    end
  end
end
