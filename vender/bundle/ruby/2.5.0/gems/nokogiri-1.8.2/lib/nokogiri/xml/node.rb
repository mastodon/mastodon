# encoding: UTF-8
require 'stringio'
require 'nokogiri/xml/node/save_options'

module Nokogiri
  module XML
    ####
    # Nokogiri::XML::Node is your window to the fun filled world of dealing
    # with XML and HTML tags.  A Nokogiri::XML::Node may be treated similarly
    # to a hash with regard to attributes.  For example (from irb):
    #
    #   irb(main):004:0> node
    #   => <a href="#foo" id="link">link</a>
    #   irb(main):005:0> node['href']
    #   => "#foo"
    #   irb(main):006:0> node.keys
    #   => ["href", "id"]
    #   irb(main):007:0> node.values
    #   => ["#foo", "link"]
    #   irb(main):008:0> node['class'] = 'green'
    #   => "green"
    #   irb(main):009:0> node
    #   => <a href="#foo" id="link" class="green">link</a>
    #   irb(main):010:0>
    #
    # See Nokogiri::XML::Node#[] and Nokogiri::XML#[]= for more information.
    #
    # Nokogiri::XML::Node also has methods that let you move around your
    # tree.  For navigating your tree, see:
    #
    # * Nokogiri::XML::Node#parent
    # * Nokogiri::XML::Node#children
    # * Nokogiri::XML::Node#next
    # * Nokogiri::XML::Node#previous
    #
    #
    # When printing or otherwise emitting a document or a node (and
    # its subtree), there are a few methods you might want to use:
    #
    # * content, text, inner_text, to_str: emit plaintext
    #
    #   These methods will all emit the plaintext version of your
    #   document, meaning that entities will be replaced (e.g., "&lt;"
    #   will be replaced with "<"), meaning that any sanitizing will
    #   likely be un-done in the output.
    #
    # * to_s, to_xml, to_html, inner_html: emit well-formed markup
    #
    #   These methods will all emit properly-escaped markup, meaning
    #   that it's suitable for consumption by browsers, parsers, etc.
    #
    # You may search this node's subtree using Searchable#xpath and Searchable#css
    class Node
      include Nokogiri::XML::PP::Node
      include Nokogiri::XML::Searchable
      include Enumerable

      # Element node type, see Nokogiri::XML::Node#element?
      ELEMENT_NODE =       1
      # Attribute node type
      ATTRIBUTE_NODE =     2
      # Text node type, see Nokogiri::XML::Node#text?
      TEXT_NODE =          3
      # CDATA node type, see Nokogiri::XML::Node#cdata?
      CDATA_SECTION_NODE = 4
      # Entity reference node type
      ENTITY_REF_NODE =    5
      # Entity node type
      ENTITY_NODE =        6
      # PI node type
      PI_NODE =            7
      # Comment node type, see Nokogiri::XML::Node#comment?
      COMMENT_NODE =       8
      # Document node type, see Nokogiri::XML::Node#xml?
      DOCUMENT_NODE =      9
      # Document type node type
      DOCUMENT_TYPE_NODE = 10
      # Document fragment node type
      DOCUMENT_FRAG_NODE = 11
      # Notation node type
      NOTATION_NODE =      12
      # HTML document node type, see Nokogiri::XML::Node#html?
      HTML_DOCUMENT_NODE = 13
      # DTD node type
      DTD_NODE =           14
      # Element declaration type
      ELEMENT_DECL =       15
      # Attribute declaration type
      ATTRIBUTE_DECL =     16
      # Entity declaration type
      ENTITY_DECL =        17
      # Namespace declaration type
      NAMESPACE_DECL =     18
      # XInclude start type
      XINCLUDE_START =     19
      # XInclude end type
      XINCLUDE_END =       20
      # DOCB document node type
      DOCB_DOCUMENT_NODE = 21

      def initialize name, document # :nodoc:
        # ... Ya.  This is empty on purpose.
      end

      ###
      # Decorate this node with the decorators set up in this node's Document
      def decorate!
        document.decorate(self)
      end

      ###
      # Search this node's immediate children using CSS selector +selector+
      def > selector
        ns = document.root.namespaces
        xpath CSS.xpath_for(selector, :prefix => "./", :ns => ns).first
      end

      ###
      # Get the attribute value for the attribute +name+
      def [] name
        get(name.to_s)
      end

      ###
      # Set the attribute value for the attribute +name+ to +value+
      def []= name, value
        set name.to_s, value.to_s
      end

      ###
      # Add +node_or_tags+ as a child of this Node.
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +<<+.
      def add_child node_or_tags
        node_or_tags = coerce(node_or_tags)
        if node_or_tags.is_a?(XML::NodeSet)
          node_or_tags.each { |n| add_child_node_and_reparent_attrs n }
        else
          add_child_node_and_reparent_attrs node_or_tags
        end
        node_or_tags
      end

      ###
      # Add +node_or_tags+ as the first child of this Node.
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +add_child+.
      def prepend_child node_or_tags
        if first = children.first
          # Mimic the error add_child would raise.
          raise RuntimeError, "Document already has a root node" if document? && !(node_or_tags.comment? || node_or_tags.processing_instruction?)
          first.__send__(:add_sibling, :previous, node_or_tags)
        else
          add_child(node_or_tags)
        end
      end

      ###
      # Add +node_or_tags+ as a child of this Node.
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns self, to support chaining of calls (e.g., root << child1 << child2)
      #
      # Also see related method +add_child+.
      def << node_or_tags
        add_child node_or_tags
        self
      end

      ###
      # Insert +node_or_tags+ before this Node (as a sibling).
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +before+.
      def add_previous_sibling node_or_tags
        raise ArgumentError.new("A document may not have multiple root nodes.") if (parent && parent.document?) && !(node_or_tags.comment? || node_or_tags.processing_instruction?)

        add_sibling :previous, node_or_tags
      end

      ###
      # Insert +node_or_tags+ after this Node (as a sibling).
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +after+.
      def add_next_sibling node_or_tags
        raise ArgumentError.new("A document may not have multiple root nodes.") if (parent && parent.document?) && !(node_or_tags.comment? || node_or_tags.processing_instruction?)

        add_sibling :next, node_or_tags
      end

      ####
      # Insert +node_or_tags+ before this node (as a sibling).
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns self, to support chaining of calls.
      #
      # Also see related method +add_previous_sibling+.
      def before node_or_tags
        add_previous_sibling node_or_tags
        self
      end

      ####
      # Insert +node_or_tags+ after this node (as a sibling).
      # +node_or_tags+ can be a Nokogiri::XML::Node, a Nokogiri::XML::DocumentFragment, or a string containing markup.
      #
      # Returns self, to support chaining of calls.
      #
      # Also see related method +add_next_sibling+.
      def after node_or_tags
        add_next_sibling node_or_tags
        self
      end

      ####
      # Set the inner html for this Node to +node_or_tags+
      # +node_or_tags+ can be a Nokogiri::XML::Node, a Nokogiri::XML::DocumentFragment, or a string containing markup.
      #
      # Returns self.
      #
      # Also see related method +children=+
      def inner_html= node_or_tags
        self.children = node_or_tags
        self
      end

      ####
      # Set the inner html for this Node +node_or_tags+
      # +node_or_tags+ can be a Nokogiri::XML::Node, a Nokogiri::XML::DocumentFragment, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +inner_html=+
      def children= node_or_tags
        node_or_tags = coerce(node_or_tags)
        children.unlink
        if node_or_tags.is_a?(XML::NodeSet)
          node_or_tags.each { |n| add_child_node_and_reparent_attrs n }
        else
          add_child_node_and_reparent_attrs node_or_tags
        end
        node_or_tags
      end

      ####
      # Replace this Node with +node_or_tags+.
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns the reparented node (if +node_or_tags+ is a Node), or NodeSet (if +node_or_tags+ is a DocumentFragment, NodeSet, or string).
      #
      # Also see related method +swap+.
      def replace node_or_tags
        # We cannot replace a text node directly, otherwise libxml will return
        # an internal error at parser.c:13031, I don't know exactly why
        # libxml is trying to find a parent node that is an element or document
        # so I can't tell if this is bug in libxml or not. issue #775.
        if text?
          replacee = Nokogiri::XML::Node.new 'dummy', document
          add_previous_sibling_node replacee
          unlink
          return replacee.replace node_or_tags
        end

        node_or_tags = coerce(node_or_tags)

        if node_or_tags.is_a?(XML::NodeSet)
          node_or_tags.each { |n| add_previous_sibling n }
          unlink
        else
          replace_node node_or_tags
        end
        node_or_tags
      end

      ####
      # Swap this Node for +node_or_tags+
      # +node_or_tags+ can be a Nokogiri::XML::Node, a ::DocumentFragment, a ::NodeSet, or a string containing markup.
      #
      # Returns self, to support chaining of calls.
      #
      # Also see related method +replace+.
      def swap node_or_tags
        replace node_or_tags
        self
      end

      alias :next           :next_sibling
      alias :previous       :previous_sibling

      # :stopdoc:
      # HACK: This is to work around an RDoc bug
      alias :next=          :add_next_sibling
      # :startdoc:

      alias :previous=      :add_previous_sibling
      alias :remove         :unlink
      alias :get_attribute  :[]
      alias :attr           :[]
      alias :set_attribute  :[]=
      alias :text           :content
      alias :inner_text     :content
      alias :has_attribute? :key?
      alias :name           :node_name
      alias :name=          :node_name=
      alias :type           :node_type
      alias :to_str         :text
      alias :clone          :dup
      alias :elements       :element_children

      ####
      # Returns a hash containing the node's attributes.  The key is
      # the attribute name without any namespace, the value is a Nokogiri::XML::Attr
      # representing the attribute.
      # If you need to distinguish attributes with the same name, with different namespaces
      # use #attribute_nodes instead.
      def attributes
        Hash[attribute_nodes.map { |node|
          [node.node_name, node]
        }]
      end

      ###
      # Get the attribute values for this Node.
      def values
        attribute_nodes.map(&:value)
      end

      ###
      # Get the attribute names for this Node.
      def keys
        attribute_nodes.map(&:node_name)
      end

      ###
      # Iterate over each attribute name and value pair for this Node.
      def each
        attribute_nodes.each { |node|
          yield [node.node_name, node.value]
        }
      end

      ###
      # Remove the attribute named +name+
      def remove_attribute name
        attr = attributes[name].remove if key? name
        clear_xpath_context if Nokogiri.jruby?
        attr
      end
      alias :delete :remove_attribute

      ###
      # Returns true if this Node matches +selector+
      def matches? selector
        ancestors.last.search(selector).include?(self)
      end

      ###
      # Create a DocumentFragment containing +tags+ that is relative to _this_
      # context node.
      def fragment tags
        type = document.html? ? Nokogiri::HTML : Nokogiri::XML
        type::DocumentFragment.new(document, tags, self)
      end

      ###
      # Parse +string_or_io+ as a document fragment within the context of
      # *this* node.  Returns a XML::NodeSet containing the nodes parsed from
      # +string_or_io+.
      def parse string_or_io, options = nil
        ##
        # When the current node is unparented and not an element node, use the
        # document as the parsing context instead. Otherwise, the in-context
        # parser cannot find an element or a document node.
        # Document Fragments are also not usable by the in-context parser.
        if !element? && !document? && (!parent || parent.fragment?)
          return document.parse(string_or_io, options)
        end

        options ||= (document.html? ? ParseOptions::DEFAULT_HTML : ParseOptions::DEFAULT_XML)
        if Integer === options
          options = Nokogiri::XML::ParseOptions.new(options)
        end
        # Give the options to the user
        yield options if block_given?

        contents = string_or_io.respond_to?(:read) ?
          string_or_io.read :
          string_or_io

        return Nokogiri::XML::NodeSet.new(document) if contents.empty?

        ##
        # This is a horrible hack, but I don't care. See #313 for background.
        error_count = document.errors.length
        node_set = in_context(contents, options.to_i)
        if node_set.empty? and document.errors.length > error_count and options.recover?
          fragment = Nokogiri::HTML::DocumentFragment.parse contents
          node_set = fragment.children
        end
        node_set
      end

      ####
      # Set the Node's content to a Text node containing +string+. The string gets XML escaped, not interpreted as markup.
      def content= string
        self.native_content = encode_special_chars(string.to_s)
      end

      ###
      # Set the parent Node for this Node
      def parent= parent_node
        parent_node.add_child(self)
        parent_node
      end

      ###
      # Returns a Hash of {prefix => value} for all namespaces on this
      # node and its ancestors.
      #
      # This method returns the same namespaces as #namespace_scopes.
      #
      # Returns namespaces in scope for self -- those defined on self
      # element directly or any ancestor node -- as a Hash of
      # attribute-name/value pairs. Note that the keys in this hash
      # XML attributes that would be used to define this namespace,
      # such as "xmlns:prefix", not just the prefix. Default namespace
      # set on self will be included with key "xmlns". However,
      # default namespaces set on ancestor will NOT be, even if self
      # has no explicit default namespace.
      def namespaces
        Hash[namespace_scopes.map { |nd|
          key = ['xmlns', nd.prefix].compact.join(':')
          [key, nd.href]
        }]
      end

      # Returns true if this is a Comment
      def comment?
        type == COMMENT_NODE
      end

      # Returns true if this is a CDATA
      def cdata?
        type == CDATA_SECTION_NODE
      end

      # Returns true if this is an XML::Document node
      def xml?
        type == DOCUMENT_NODE
      end

      # Returns true if this is an HTML::Document node
      def html?
        type == HTML_DOCUMENT_NODE
      end

      # Returns true if this is a Document
      def document?
        is_a? XML::Document
      end

      # Returns true if this is a ProcessingInstruction node
      def processing_instruction?
        type == PI_NODE
      end

      # Returns true if this is a Text node
      def text?
        type == TEXT_NODE
      end

      # Returns true if this is a DocumentFragment
      def fragment?
        type == DOCUMENT_FRAG_NODE
      end

      ###
      # Fetch the Nokogiri::HTML::ElementDescription for this node.  Returns
      # nil on XML documents and on unknown tags.
      def description
        return nil if document.xml?
        Nokogiri::HTML::ElementDescription[name]
      end

      ###
      # Is this a read only node?
      def read_only?
        # According to gdome2, these are read-only node types
        [NOTATION_NODE, ENTITY_NODE, ENTITY_DECL].include?(type)
      end

      # Returns true if this is an Element node
      def element?
        type == ELEMENT_NODE
      end
      alias :elem? :element?

      ###
      # Turn this node in to a string.  If the document is HTML, this method
      # returns html.  If the document is XML, this method returns XML.
      def to_s
        document.xml? ? to_xml : to_html
      end

      # Get the inner_html for this node's Node#children
      def inner_html *args
        children.map { |x| x.to_html(*args) }.join
      end

      # Get the path to this node as a CSS expression
      def css_path
        path.split(/\//).map { |part|
          part.length == 0 ? nil : part.gsub(/\[(\d+)\]/, ':nth-of-type(\1)')
        }.compact.join(' > ')
      end

      ###
      # Get a list of ancestor Node for this Node.  If +selector+ is given,
      # the ancestors must match +selector+
      def ancestors selector = nil
        return NodeSet.new(document) unless respond_to?(:parent)
        return NodeSet.new(document) unless parent

        parents = [parent]

        while parents.last.respond_to?(:parent)
          break unless ctx_parent = parents.last.parent
          parents << ctx_parent
        end

        return NodeSet.new(document, parents) unless selector

        root = parents.last
        search_results = root.search(selector)

        NodeSet.new(document, parents.find_all { |parent|
          search_results.include?(parent)
        })
      end

      ###
      # Adds a default namespace supplied as a string +url+ href, to self.
      # The consequence is as an xmlns attribute with supplied argument were
      # present in parsed XML.  A default namespace set with this method will
      # now show up in #attributes, but when this node is serialized to XML an
      # "xmlns" attribute will appear. See also #namespace and #namespace=
      def default_namespace= url
        add_namespace_definition(nil, url)
      end
      alias :add_namespace :add_namespace_definition

      ###
      # Set the default namespace on this node (as would be defined with an
      # "xmlns=" attribute in XML source), as a Namespace object +ns+. Note that
      # a Namespace added this way will NOT be serialized as an xmlns attribute
      # for this node. You probably want #default_namespace= instead, or perhaps
      # #add_namespace_definition with a nil prefix argument.
      def namespace= ns
        return set_namespace(ns) unless ns

        unless Nokogiri::XML::Namespace === ns
          raise TypeError, "#{ns.class} can't be coerced into Nokogiri::XML::Namespace"
        end
        if ns.document != document
          raise ArgumentError, 'namespace must be declared on the same document'
        end

        set_namespace ns
      end

      ####
      # Yields self and all children to +block+ recursively.
      def traverse &block
        children.each{|j| j.traverse(&block) }
        block.call(self)
      end

      ###
      # Accept a visitor.  This method calls "visit" on +visitor+ with self.
      def accept visitor
        visitor.visit(self)
      end

      ###
      # Test to see if this Node is equal to +other+
      def == other
        return false unless other
        return false unless other.respond_to?(:pointer_id)
        pointer_id == other.pointer_id
      end

      ###
      # Serialize Node using +options+.  Save options can also be set using a
      # block. See SaveOptions.
      #
      # These two statements are equivalent:
      #
      #  node.serialize(:encoding => 'UTF-8', :save_with => FORMAT | AS_XML)
      #
      # or
      #
      #   node.serialize(:encoding => 'UTF-8') do |config|
      #     config.format.as_xml
      #   end
      #
      def serialize *args, &block
        options = args.first.is_a?(Hash) ? args.shift : {
          :encoding   => args[0],
          :save_with  => args[1]
        }

        encoding = options[:encoding] || document.encoding
        options[:encoding] = encoding

        outstring = String.new
        outstring.force_encoding(Encoding.find(encoding || 'utf-8'))
        io = StringIO.new(outstring)
        write_to io, options, &block
        io.string
      end

      ###
      # Serialize this Node to HTML
      #
      #   doc.to_html
      #
      # See Node#write_to for a list of +options+.  For formatted output,
      # use Node#to_xhtml instead.
      def to_html options = {}
        to_format SaveOptions::DEFAULT_HTML, options
      end

      ###
      # Serialize this Node to XML using +options+
      #
      #   doc.to_xml(:indent => 5, :encoding => 'UTF-8')
      #
      # See Node#write_to for a list of +options+
      def to_xml options = {}
        options[:save_with] ||= SaveOptions::DEFAULT_XML
        serialize(options)
      end

      ###
      # Serialize this Node to XHTML using +options+
      #
      #   doc.to_xhtml(:indent => 5, :encoding => 'UTF-8')
      #
      # See Node#write_to for a list of +options+
      def to_xhtml options = {}
        to_format SaveOptions::DEFAULT_XHTML, options
      end

      ###
      # Write Node to +io+ with +options+. +options+ modify the output of
      # this method.  Valid options are:
      #
      # * +:encoding+ for changing the encoding
      # * +:indent_text+ the indentation text, defaults to one space
      # * +:indent+ the number of +:indent_text+ to use, defaults to 2
      # * +:save_with+ a combination of SaveOptions constants.
      #
      # To save with UTF-8 indented twice:
      #
      #   node.write_to(io, :encoding => 'UTF-8', :indent => 2)
      #
      # To save indented with two dashes:
      #
      #   node.write_to(io, :indent_text => '-', :indent => 2)
      #
      def write_to io, *options
        options       = options.first.is_a?(Hash) ? options.shift : {}
        encoding      = options[:encoding] || options[0]
        if Nokogiri.jruby?
          save_options  = options[:save_with] || options[1]
          indent_times  = options[:indent] || 0
        else
          save_options  = options[:save_with] || options[1] || SaveOptions::FORMAT
          indent_times  = options[:indent] || 2
        end
        indent_text   = options[:indent_text] || ' '

        config = SaveOptions.new(save_options.to_i)
        yield config if block_given?

        native_write_to(io, encoding, indent_text * indent_times, config.options)
      end

      ###
      # Write Node as HTML to +io+ with +options+
      #
      # See Node#write_to for a list of +options+
      def write_html_to io, options = {}
        write_format_to SaveOptions::DEFAULT_HTML, io, options
      end

      ###
      # Write Node as XHTML to +io+ with +options+
      #
      # See Node#write_to for a list of +options+
      def write_xhtml_to io, options = {}
        write_format_to SaveOptions::DEFAULT_XHTML, io, options
      end

      ###
      # Write Node as XML to +io+ with +options+
      #
      #   doc.write_xml_to io, :encoding => 'UTF-8'
      #
      # See Node#write_to for a list of options
      def write_xml_to io, options = {}
        options[:save_with] ||= SaveOptions::DEFAULT_XML
        write_to io, options
      end

      ###
      # Compare two Node objects with respect to their Document.  Nodes from
      # different documents cannot be compared.
      def <=> other
        return nil unless other.is_a?(Nokogiri::XML::Node)
        return nil unless document == other.document
        compare other
      end

      ###
      # Do xinclude substitution on the subtree below node. If given a block, a
      # Nokogiri::XML::ParseOptions object initialized from +options+, will be
      # passed to it, allowing more convenient modification of the parser options.
      def do_xinclude options = XML::ParseOptions::DEFAULT_XML, &block
        options = Nokogiri::XML::ParseOptions.new(options) if Integer === options

        # give options to user
        yield options if block_given?

        # call c extension
        process_xincludes(options.to_i)
      end

      def canonicalize(mode=XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false)
        c14n_root = self
        document.canonicalize(mode, inclusive_namespaces, with_comments) do |node, parent|
          tn = node.is_a?(XML::Node) ? node : parent
          tn == c14n_root || tn.ancestors.include?(c14n_root)
        end
      end

      private

      def add_sibling next_or_previous, node_or_tags
        impl = (next_or_previous == :next) ? :add_next_sibling_node : :add_previous_sibling_node
        iter = (next_or_previous == :next) ? :reverse_each          : :each

        node_or_tags = coerce node_or_tags
        if node_or_tags.is_a?(XML::NodeSet)
          if text?
            pivot = Nokogiri::XML::Node.new 'dummy', document
            send impl, pivot
          else
            pivot = self
          end
          node_or_tags.send(iter) { |n| pivot.send impl, n }
          pivot.unlink if text?
        else
          send impl, node_or_tags
        end
        node_or_tags
      end

      def to_format save_option, options
        # FIXME: this is a hack around broken libxml versions
        return dump_html if Nokogiri.uses_libxml? && %w[2 6] === LIBXML_VERSION.split('.')[0..1]

        options[:save_with] = save_option unless options[:save_with]
        serialize(options)
      end

      def write_format_to save_option, io, options
        # FIXME: this is a hack around broken libxml versions
        return (io << dump_html) if Nokogiri.uses_libxml? && %w[2 6] === LIBXML_VERSION.split('.')[0..1]

        options[:save_with] ||= save_option
        write_to io, options
      end

      def inspect_attributes
        [:name, :namespace, :attribute_nodes, :children]
      end

      def coerce data # :nodoc:
        case data
        when XML::NodeSet
          return data
        when XML::DocumentFragment
          return data.children
        when String
          return fragment(data).children
        when Document, XML::Attr
          # unacceptable
        when XML::Node
          return data
        end

        raise ArgumentError, <<-EOERR
Requires a Node, NodeSet or String argument, and cannot accept a #{data.class}.
(You probably want to select a node from the Document with at() or search(), or create a new Node via Node.new().)
        EOERR
      end

      # @private
      IMPLIED_XPATH_CONTEXTS = [ './/'.freeze ].freeze # :nodoc:

      def add_child_node_and_reparent_attrs node # :nodoc:
        add_child_node node
        node.attribute_nodes.find_all { |a| a.name =~ /:/ }.each do |attr_node|
          attr_node.remove
          node[attr_node.name] = attr_node.value
        end
      end
    end
  end
end
