module Nokogiri
  module XML
    ##
    # Nokogiri::XML::Document is the main entry point for dealing with
    # XML documents.  The Document is created by parsing an XML document.
    # See Nokogiri::XML::Document.parse() for more information on parsing.
    #
    # For searching a Document, see Nokogiri::XML::Searchable#css and
    # Nokogiri::XML::Searchable#xpath
    #
    class Document < Nokogiri::XML::Node
      # I'm ignoring unicode characters here.
      # See http://www.w3.org/TR/REC-xml-names/#ns-decl for more details.
      NCNAME_START_CHAR = "A-Za-z_"
      NCNAME_CHAR       = NCNAME_START_CHAR + "\\-.0-9"
      NCNAME_RE         = /^xmlns(:[#{NCNAME_START_CHAR}][#{NCNAME_CHAR}]*)?$/

      ##
      # Parse an XML file.
      #
      # +string_or_io+ may be a String, or any object that responds to
      # _read_ and _close_ such as an IO, or StringIO.
      #
      # +url+ (optional) is the URI where this document is located.
      #
      # +encoding+ (optional) is the encoding that should be used when processing
      # the document.
      #
      # +options+ (optional) is a configuration object that sets options during
      # parsing, such as Nokogiri::XML::ParseOptions::RECOVER. See the
      # Nokogiri::XML::ParseOptions for more information.
      #
      # +block+ (optional) is passed a configuration object on which
      # parse options may be set.
      #
      # By default, Nokogiri treats documents as untrusted, and so
      # does not attempt to load DTDs or access the network. See
      # Nokogiri::XML::ParseOptions for a complete list of options;
      # and that module's DEFAULT_XML constant for what's set (and not
      # set) by default.
      #
      # Nokogiri.XML() is a convenience method which will call this method.
      #
      def self.parse string_or_io, url = nil, encoding = nil, options = ParseOptions::DEFAULT_XML, &block
        options = Nokogiri::XML::ParseOptions.new(options) if Integer === options
        # Give the options to the user
        yield options if block_given?

        if empty_doc?(string_or_io)
          if options.strict?
            raise Nokogiri::XML::SyntaxError.new("Empty document")
          else
            return encoding ? new.tap { |i| i.encoding = encoding } : new
          end
        end

        doc = if string_or_io.respond_to?(:read)
          url ||= string_or_io.respond_to?(:path) ? string_or_io.path : nil
          read_io(string_or_io, url, encoding, options.to_i)
        else
          # read_memory pukes on empty docs
          read_memory(string_or_io, url, encoding, options.to_i)
        end

        # do xinclude processing
        doc.do_xinclude(options) if options.xinclude?

        return doc
      end

      # A list of Nokogiri::XML::SyntaxError found when parsing a document
      attr_accessor :errors

      def initialize *args # :nodoc:
        @errors     = []
        @decorators = nil
      end

      ##
      # Create an element with +name+, and optionally setting the content and attributes.
      #
      #   doc.create_element "div" # <div></div>
      #   doc.create_element "div", :class => "container" # <div class='container'></div>
      #   doc.create_element "div", "contents" # <div>contents</div>
      #   doc.create_element "div", "contents", :class => "container" # <div class='container'>contents</div>
      #   doc.create_element "div" { |node| node['class'] = "container" } # <div class='container'></div>
      #
      def create_element name, *args, &block
        elm = Nokogiri::XML::Element.new(name, self, &block)
        args.each do |arg|
          case arg
          when Hash
            arg.each { |k,v|
              key = k.to_s
              if key =~ NCNAME_RE
                ns_name = key.split(":", 2)[1]
                elm.add_namespace_definition ns_name, v
              else
                elm[k.to_s] = v.to_s
              end
            }
          else
            elm.content = arg
          end
        end
        if ns = elm.namespace_definitions.find { |n| n.prefix.nil? or n.prefix == '' }
          elm.namespace = ns
        end
        elm
      end

      # Create a Text Node with +string+
      def create_text_node string, &block
        Nokogiri::XML::Text.new string.to_s, self, &block
      end

      # Create a CDATA Node containing +string+
      def create_cdata string, &block
        Nokogiri::XML::CDATA.new self, string.to_s, &block
      end

      # Create a Comment Node containing +string+
      def create_comment string, &block
        Nokogiri::XML::Comment.new self, string.to_s, &block
      end

      # The name of this document.  Always returns "document"
      def name
        'document'
      end

      # A reference to +self+
      def document
        self
      end

      ##
      # Recursively get all namespaces from this node and its subtree and
      # return them as a hash.
      #
      # For example, given this document:
      #
      #   <root xmlns:foo="bar">
      #     <bar xmlns:hello="world" />
      #   </root>
      #
      # This method will return:
      #
      #   { 'xmlns:foo' => 'bar', 'xmlns:hello' => 'world' }
      #
      # WARNING: this method will clobber duplicate names in the keys.
      # For example, given this document:
      #
      #   <root xmlns:foo="bar">
      #     <bar xmlns:foo="baz" />
      #   </root>
      #
      # The hash returned will look like this: { 'xmlns:foo' => 'bar' }
      #
      # Non-prefixed default namespaces (as in "xmlns=") are not included
      # in the hash.
      #
      # Note that this method does an xpath lookup for nodes with
      # namespaces, and as a result the order may be dependent on the
      # implementation of the underlying XML library.
      #
      def collect_namespaces
        xpath("//namespace::*").inject({}) do |hash, ns|
          hash[["xmlns",ns.prefix].compact.join(":")] = ns.href if ns.prefix != "xml"
          hash
        end
      end

      # Get the list of decorators given +key+
      def decorators key
        @decorators ||= Hash.new
        @decorators[key] ||= []
      end

      ##
      # Validate this Document against it's DTD.  Returns a list of errors on
      # the document or +nil+ when there is no DTD.
      def validate
        return nil unless internal_subset
        internal_subset.validate self
      end

      ##
      # Explore a document with shortcut methods. See Nokogiri::Slop for details.
      #
      # Note that any nodes that have been instantiated before #slop!
      # is called will not be decorated with sloppy behavior. So, if you're in
      # irb, the preferred idiom is:
      #
      #   irb> doc = Nokogiri::Slop my_markup
      #
      # and not
      #
      #   irb> doc = Nokogiri::HTML my_markup
      #   ... followed by irb's implicit inspect (and therefore instantiation of every node) ...
      #   irb> doc.slop!
      #   ... which does absolutely nothing.
      #
      def slop!
        unless decorators(XML::Node).include? Nokogiri::Decorators::Slop
          decorators(XML::Node) << Nokogiri::Decorators::Slop
          decorate!
        end

        self
      end

      ##
      # Apply any decorators to +node+
      def decorate node
        return unless @decorators
        @decorators.each { |klass,list|
          next unless node.is_a?(klass)
          list.each { |moodule| node.extend(moodule) }
        }
      end

      alias :to_xml :serialize
      alias :clone :dup

      # Get the hash of namespaces on the root Nokogiri::XML::Node
      def namespaces
        root ? root.namespaces : {}
      end

      ##
      # Create a Nokogiri::XML::DocumentFragment from +tags+
      # Returns an empty fragment if +tags+ is nil.
      def fragment tags = nil
        DocumentFragment.new(self, tags, self.root)
      end

      undef_method :swap, :parent, :namespace, :default_namespace=
      undef_method :add_namespace_definition, :attributes
      undef_method :namespace_definitions, :line, :add_namespace

      def add_child node_or_tags
        raise "A document may not have multiple root nodes." if (root && root.name != 'nokogiri_text_wrapper') && !(node_or_tags.comment? || node_or_tags.processing_instruction?)
        node_or_tags = coerce(node_or_tags)
        if node_or_tags.is_a?(XML::NodeSet)
          raise "A document may not have multiple root nodes." if node_or_tags.size > 1
          super(node_or_tags.first)
        else
          super
        end
      end
      alias :<< :add_child

      ##
      # +JRuby+
      # Wraps Java's org.w3c.dom.document and returns Nokogiri::XML::Document
      def self.wrap document
        raise "JRuby only method" unless Nokogiri.jruby?
        return wrapJavaDocument(document)
      end

      ##
      # +JRuby+
      # Returns Java's org.w3c.dom.document of this Document.
      def to_java
        raise "JRuby only method" unless Nokogiri.jruby?
        return toJavaDocument()
      end

      private
      def self.empty_doc? string_or_io
        string_or_io.nil? ||
          (string_or_io.respond_to?(:empty?) && string_or_io.empty?) ||
          (string_or_io.respond_to?(:eof?) && string_or_io.eof?)
      end

      # @private
      IMPLIED_XPATH_CONTEXTS = [ '//'.freeze ].freeze # :nodoc:

      def inspect_attributes
        [:name, :children]
      end
    end
  end
end
