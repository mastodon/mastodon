module Loofah
  #
  #  Loofah provides some built-in scrubbers for sanitizing with
  #  HTML5lib's whitelist and for accomplishing some common
  #  transformation tasks.
  #
  #
  #  === Loofah::Scrubbers::Strip / scrub!(:strip)
  #
  #  +:strip+ removes unknown/unsafe tags, but leaves behind the pristine contents:
  #
  #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
  #     Loofah.fragment(unsafe_html).scrub!(:strip)
  #     => "ohai! <div>div is safe</div> but foo is <b>not</b>"
  #
  #
  #  === Loofah::Scrubbers::Prune / scrub!(:prune)
  #
  #  +:prune+ removes unknown/unsafe tags and their contents (including their subtrees):
  #
  #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
  #     Loofah.fragment(unsafe_html).scrub!(:prune)
  #     => "ohai! <div>div is safe</div> "
  #
  #
  #  === Loofah::Scrubbers::Escape / scrub!(:escape)
  #
  #  +:escape+ performs HTML entity escaping on the unknown/unsafe tags:
  #
  #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
  #     Loofah.fragment(unsafe_html).scrub!(:escape)
  #     => "ohai! <div>div is safe</div> &lt;foo&gt;but foo is &lt;b&gt;not&lt;/b&gt;&lt;/foo&gt;"
  #
  #
  #  === Loofah::Scrubbers::Whitewash / scrub!(:whitewash)
  #
  #  +:whitewash+ removes all comments, styling and attributes in
  #  addition to doing markup-fixer-uppery and pruning unsafe tags. I
  #  like to call this "whitewashing", since it's like putting a new
  #  layer of paint on top of the HTML input to make it look nice.
  #
  #     messy_markup = "ohai! <div id='foo' class='bar' style='margin: 10px'>div with attributes</div>"
  #     Loofah.fragment(messy_markup).scrub!(:whitewash)
  #     => "ohai! <div>div with attributes</div>"
  #
  #  One use case for this scrubber is to clean up HTML that was
  #  cut-and-pasted from Microsoft Word into a WYSIWYG editor or a
  #  rich text editor. Microsoft's software is famous for injecting
  #  all kinds of cruft into its HTML output. Who needs that crap?
  #  Certainly not me.
  #
  #
  #  === Loofah::Scrubbers::NoFollow / scrub!(:nofollow)
  #
  #  +:nofollow+ adds a rel="nofollow" attribute to all links
  #
  #     link_farmers_markup = "ohai! <a href='http://www.myswarmysite.com/'>I like your blog post</a>"
  #     Loofah.fragment(link_farmers_markup).scrub!(:nofollow)
  #     => "ohai! <a href='http://www.myswarmysite.com/' rel="nofollow">I like your blog post</a>"
  #
  #
  #  === Loofah::Scrubbers::NoOpener / scrub!(:noopener)
  #
  #  +:noopener+ adds a rel="noopener" attribute to all links
  #
  #     link_farmers_markup = "ohai! <a href='http://www.myswarmysite.com/'>I like your blog post</a>"
  #     Loofah.fragment(link_farmers_markup).scrub!(:noopener)
  #     => "ohai! <a href='http://www.myswarmysite.com/' rel="noopener">I like your blog post</a>"
  #
  #
  #  === Loofah::Scrubbers::Unprintable / scrub!(:unprintable)
  #
  #  +:unprintable+ removes unprintable Unicode characters.
  #
  #     markup = "<p>Some text with an unprintable character at the end\u2028</p>"
  #     Loofah.fragment(markup).scrub!(:unprintable)
  #     => "<p>Some text with an unprintable character at the end</p>"
  #
  #  You may not be able to see the unprintable character in the above example, but there is a
  #  U+2028 character right before the closing </p> tag. These characters can cause issues if
  #  the content is ever parsed by JavaScript - more information here:
  #
  #     http://timelessrepo.com/json-isnt-a-javascript-subset
  #
  module Scrubbers
    #
    #  === scrub!(:strip)
    #
    #  +:strip+ removes unknown/unsafe tags, but leaves behind the pristine contents:
    #
    #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
    #     Loofah.fragment(unsafe_html).scrub!(:strip)
    #     => "ohai! <div>div is safe</div> but foo is <b>not</b>"
    #
    class Strip < Scrubber
      def initialize
        @direction = :bottom_up
      end

      def scrub(node)
        return CONTINUE if html5lib_sanitize(node) == CONTINUE
        if node.children.length == 1 && node.children.first.cdata?
          sanitized_text = Loofah.fragment(node.children.first.to_html).scrub!(:strip).to_html
          node.before Nokogiri::XML::Text.new(sanitized_text, node.document)
        else
          node.before node.children
        end
        node.remove
      end
    end

    #
    #  === scrub!(:prune)
    #
    #  +:prune+ removes unknown/unsafe tags and their contents (including their subtrees):
    #
    #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
    #     Loofah.fragment(unsafe_html).scrub!(:prune)
    #     => "ohai! <div>div is safe</div> "
    #
    class Prune < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return CONTINUE if html5lib_sanitize(node) == CONTINUE
        node.remove
        return STOP
      end
    end

    #
    #  === scrub!(:escape)
    #
    #  +:escape+ performs HTML entity escaping on the unknown/unsafe tags:
    #
    #     unsafe_html = "ohai! <div>div is safe</div> <foo>but foo is <b>not</b></foo>"
    #     Loofah.fragment(unsafe_html).scrub!(:escape)
    #     => "ohai! <div>div is safe</div> &lt;foo&gt;but foo is &lt;b&gt;not&lt;/b&gt;&lt;/foo&gt;"
    #
    class Escape < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return CONTINUE if html5lib_sanitize(node) == CONTINUE
        node.add_next_sibling Nokogiri::XML::Text.new(node.to_s, node.document)
        node.remove
        return STOP
      end
    end

    #
    #  === scrub!(:whitewash)
    #
    #  +:whitewash+ removes all comments, styling and attributes in
    #  addition to doing markup-fixer-uppery and pruning unsafe tags. I
    #  like to call this "whitewashing", since it's like putting a new
    #  layer of paint on top of the HTML input to make it look nice.
    #
    #     messy_markup = "ohai! <div id='foo' class='bar' style='margin: 10px'>div with attributes</div>"
    #     Loofah.fragment(messy_markup).scrub!(:whitewash)
    #     => "ohai! <div>div with attributes</div>"
    #
    #  One use case for this scrubber is to clean up HTML that was
    #  cut-and-pasted from Microsoft Word into a WYSIWYG editor or a
    #  rich text editor. Microsoft's software is famous for injecting
    #  all kinds of cruft into its HTML output. Who needs that crap?
    #  Certainly not me.
    #
    class Whitewash < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HTML5::Scrub.allowed_element? node.name
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return CONTINUE if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return CONTINUE
        end
        node.remove
        STOP
      end
    end

    #
    #  === scrub!(:nofollow)
    #
    #  +:nofollow+ adds a rel="nofollow" attribute to all links
    #
    #     link_farmers_markup = "ohai! <a href='http://www.myswarmysite.com/'>I like your blog post</a>"
    #     Loofah.fragment(link_farmers_markup).scrub!(:nofollow)
    #     => "ohai! <a href='http://www.myswarmysite.com/' rel="nofollow">I like your blog post</a>"
    #
    class NoFollow < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return CONTINUE unless (node.type == Nokogiri::XML::Node::ELEMENT_NODE) && (node.name == 'a')
        append_attribute(node, 'rel', 'nofollow')
        return STOP
      end
    end

    #
    #  === scrub!(:noopener)
    #
    #  +:noopener+ adds a rel="noopener" attribute to all links
    #
    #     link_farmers_markup = "ohai! <a href='http://www.myswarmysite.com/'>I like your blog post</a>"
    #     Loofah.fragment(link_farmers_markup).scrub!(:noopener)
    #     => "ohai! <a href='http://www.myswarmysite.com/' rel="noopener">I like your blog post</a>"
    #
    class NoOpener < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        return CONTINUE unless (node.type == Nokogiri::XML::Node::ELEMENT_NODE) && (node.name == 'a')
        append_attribute(node, 'rel', 'noopener')
        return STOP
      end
    end

    # This class probably isn't useful publicly, but is used for #to_text's current implemention
    class NewlineBlockElements < Scrubber # :nodoc:
      def initialize
        @direction = :bottom_up
      end

      def scrub(node)
        return CONTINUE unless Loofah::Elements::BLOCK_LEVEL.include?(node.name)
        node.add_next_sibling Nokogiri::XML::Text.new("\n#{node.content}\n", node.document)
        node.remove
      end
    end

    #
    #  === scrub!(:unprintable)
    #
    #  +:unprintable+ removes unprintable Unicode characters.
    #
    #     markup = "<p>Some text with an unprintable character at the end\u2028</p>"
    #     Loofah.fragment(markup).scrub!(:unprintable)
    #     => "<p>Some text with an unprintable character at the end</p>"
    #
    #  You may not be able to see the unprintable character in the above example, but there is a
    #  U+2028 character right before the closing </p> tag. These characters can cause issues if
    #  the content is ever parsed by JavaScript - more information here:
    #
    #     http://timelessrepo.com/json-isnt-a-javascript-subset
    #
    class Unprintable < Scrubber
      def initialize
        @direction = :top_down
      end

      def scrub(node)
        if node.type == Nokogiri::XML::Node::TEXT_NODE || node.type == Nokogiri::XML::Node::CDATA_SECTION_NODE
          node.content = node.content.gsub(/\u2028|\u2029/, '')
        end
        CONTINUE
      end
    end

    #
    #  A hash that maps a symbol (like +:prune+) to the appropriate Scrubber (Loofah::Scrubbers::Prune).
    #
    MAP = {
      :escape    => Escape,
      :prune     => Prune,
      :whitewash => Whitewash,
      :strip     => Strip,
      :nofollow  => NoFollow,
      :noopener => NoOpener,
      :newline_block_elements => NewlineBlockElements,
      :unprintable => Unprintable
    }

    #
    #  Returns an array of symbols representing the built-in scrubbers
    #
    def self.scrubber_symbols
      MAP.keys
    end
  end
end
