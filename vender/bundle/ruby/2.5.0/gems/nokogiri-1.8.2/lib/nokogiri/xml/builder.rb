module Nokogiri
  module XML
    ###
    # Nokogiri builder can be used for building XML and HTML documents.
    #
    # == Synopsis:
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.root {
    #       xml.products {
    #         xml.widget {
    #           xml.id_ "10"
    #           xml.name "Awesome widget"
    #         }
    #       }
    #     }
    #   end
    #   puts builder.to_xml
    #
    # Will output:
    #
    #   <?xml version="1.0"?>
    #   <root>
    #     <products>
    #       <widget>
    #         <id>10</id>
    #         <name>Awesome widget</name>
    #       </widget>
    #     </products>
    #   </root>
    #
    #
    # === Builder scope
    #
    # The builder allows two forms.  When the builder is supplied with a block
    # that has a parameter, the outside scope is maintained.  This means you
    # can access variables that are outside your builder.  If you don't need
    # outside scope, you can use the builder without the "xml" prefix like
    # this:
    #
    #   builder = Nokogiri::XML::Builder.new do
    #     root {
    #       products {
    #         widget {
    #           id_ "10"
    #           name "Awesome widget"
    #         }
    #       }
    #     }
    #   end
    #
    # == Special Tags
    #
    # The builder works by taking advantage of method_missing.  Unfortunately
    # some methods are defined in ruby that are difficult or dangerous to
    # remove.  You may want to create tags with the name "type", "class", and
    # "id" for example.  In that case, you can use an underscore to
    # disambiguate your tag name from the method call.
    #
    # Here is an example of using the underscore to disambiguate tag names from
    # ruby methods:
    #
    #   @objects = [Object.new, Object.new, Object.new]
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.root {
    #       xml.objects {
    #         @objects.each do |o|
    #           xml.object {
    #             xml.type_   o.type
    #             xml.class_  o.class.name
    #             xml.id_     o.id
    #           }
    #         end
    #       }
    #     }
    #   end
    #   puts builder.to_xml
    #
    # The underscore may be used with any tag name, and the last underscore
    # will just be removed.  This code will output the following XML:
    #
    #   <?xml version="1.0"?>
    #   <root>
    #     <objects>
    #       <object>
    #         <type>Object</type>
    #         <class>Object</class>
    #         <id>48390</id>
    #       </object>
    #       <object>
    #         <type>Object</type>
    #         <class>Object</class>
    #         <id>48380</id>
    #       </object>
    #       <object>
    #         <type>Object</type>
    #         <class>Object</class>
    #         <id>48370</id>
    #       </object>
    #     </objects>
    #   </root>
    #
    # == Tag Attributes
    #
    # Tag attributes may be supplied as method arguments.  Here is our
    # previous example, but using attributes rather than tags:
    #
    #   @objects = [Object.new, Object.new, Object.new]
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.root {
    #       xml.objects {
    #         @objects.each do |o|
    #           xml.object(:type => o.type, :class => o.class, :id => o.id)
    #         end
    #       }
    #     }
    #   end
    #   puts builder.to_xml
    #
    # === Tag Attribute Short Cuts
    #
    # A couple attribute short cuts are available when building tags.  The
    # short cuts are available by special method calls when building a tag.
    #
    # This example builds an "object" tag with the class attribute "classy"
    # and the id of "thing":
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.root {
    #       xml.objects {
    #         xml.object.classy.thing!
    #       }
    #     }
    #   end
    #   puts builder.to_xml
    #
    # Which will output:
    #
    #   <?xml version="1.0"?>
    #   <root>
    #     <objects>
    #       <object class="classy" id="thing"/>
    #     </objects>
    #   </root>
    #
    # All other options are still supported with this syntax, including
    # blocks and extra tag attributes.
    #
    # == Namespaces
    #
    # Namespaces are added similarly to attributes.  Nokogiri::XML::Builder
    # assumes that when an attribute starts with "xmlns", it is meant to be
    # a namespace:
    #
    #   builder = Nokogiri::XML::Builder.new { |xml|
    #     xml.root('xmlns' => 'default', 'xmlns:foo' => 'bar') do
    #       xml.tenderlove
    #     end
    #   }
    #   puts builder.to_xml
    #
    # Will output XML like this:
    #
    #   <?xml version="1.0"?>
    #   <root xmlns:foo="bar" xmlns="default">
    #     <tenderlove/>
    #   </root>
    #
    # === Referencing declared namespaces
    #
    # Tags that reference non-default namespaces (i.e. a tag "foo:bar") can be
    # built by using the Nokogiri::XML::Builder#[] method.
    #
    # For example:
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.root('xmlns:foo' => 'bar') {
    #       xml.objects {
    #         xml['foo'].object.classy.thing!
    #       }
    #     }
    #   end
    #   puts builder.to_xml
    #
    # Will output this XML:
    #
    #   <?xml version="1.0"?>
    #   <root xmlns:foo="bar">
    #     <objects>
    #       <foo:object class="classy" id="thing"/>
    #     </objects>
    #   </root>
    #
    # Note the "foo:object" tag.
    #
    # == Document Types
    #
    # To create a document type (DTD), access use the Builder#doc method to get
    # the current context document.  Then call Node#create_internal_subset to
    # create the DTD node.
    #
    # For example, this Ruby:
    #
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.doc.create_internal_subset(
    #       'html',
    #       "-//W3C//DTD HTML 4.01 Transitional//EN",
    #       "http://www.w3.org/TR/html4/loose.dtd"
    #     )
    #     xml.root do
    #       xml.foo
    #     end
    #   end
    #   
    #   puts builder.to_xml
    #
    # Will output this xml:
    #
    #   <?xml version="1.0"?>
    #   <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    #   <root>
    #     <foo/>
    #   </root>
    #
    class Builder
      # The current Document object being built
      attr_accessor :doc

      # The parent of the current node being built
      attr_accessor :parent

      # A context object for use when the block has no arguments
      attr_accessor :context

      attr_accessor :arity # :nodoc:

      ###
      # Create a builder with an existing root object.  This is for use when
      # you have an existing document that you would like to augment with
      # builder methods.  The builder context created will start with the
      # given +root+ node.
      #
      # For example:
      #
      #   doc = Nokogiri::XML(open('somedoc.xml'))
      #   Nokogiri::XML::Builder.with(doc.at('some_tag')) do |xml|
      #     # ... Use normal builder methods here ...
      #     xml.awesome # add the "awesome" tag below "some_tag"
      #   end
      #
      def self.with root, &block
        new({}, root, &block)
      end

      ###
      # Create a new Builder object.  +options+ are sent to the top level
      # Document that is being built.
      #
      # Building a document with a particular encoding for example:
      #
      #   Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      #     ...
      #   end
      def initialize options = {}, root = nil, &block

        if root
          @doc    = root.document
          @parent = root
        else
          namespace     = self.class.name.split('::')
          namespace[-1] = 'Document'
          @doc          = eval(namespace.join('::')).new
          @parent       = @doc
        end

        @context  = nil
        @arity    = nil
        @ns       = nil

        options.each do |k,v|
          @doc.send(:"#{k}=", v)
        end

        return unless block_given?

        @arity = block.arity
        if @arity <= 0
          @context = eval('self', block.binding)
          instance_eval(&block)
        else
          yield self
        end

        @parent = @doc
      end

      ###
      # Create a Text Node with content of +string+
      def text string
        insert @doc.create_text_node(string)
      end

      ###
      # Create a CDATA Node with content of +string+
      def cdata string
        insert doc.create_cdata(string)
      end

      ###
      # Create a Comment Node with content of +string+
      def comment string
        insert doc.create_comment(string)
      end

      ###
      # Build a tag that is associated with namespace +ns+.  Raises an
      # ArgumentError if +ns+ has not been defined higher in the tree.
      def [] ns
        if @parent != @doc
          @ns = @parent.namespace_definitions.find { |x| x.prefix == ns.to_s }
        end
        return self if @ns

        @parent.ancestors.each do |a|
          next if a == doc
          @ns = a.namespace_definitions.find { |x| x.prefix == ns.to_s }
          return self if @ns
        end

        @ns = { :pending => ns.to_s }
        return self
      end

      ###
      # Convert this Builder object to XML
      def to_xml(*args)
        if Nokogiri.jruby?
          options = args.first.is_a?(Hash) ? args.shift : {}
          if !options[:save_with]
            options[:save_with] = Node::SaveOptions::AS_BUILDER
          end
          args.insert(0, options)
        end
        @doc.to_xml(*args)
      end

      ###
      # Append the given raw XML +string+ to the document
      def << string
        @doc.fragment(string).children.each { |x| insert(x) }
      end

      def method_missing method, *args, &block # :nodoc:
        if @context && @context.respond_to?(method)
          @context.send(method, *args, &block)
        else
          node = @doc.create_element(method.to_s.sub(/[_!]$/, ''),*args) { |n|
            # Set up the namespace
            if @ns.is_a? Nokogiri::XML::Namespace
              n.namespace = @ns
              @ns = nil
            end
          }

          if @ns.is_a? Hash
            node.namespace = node.namespace_definitions.find { |x| x.prefix == @ns[:pending] }
            if node.namespace.nil?
              raise ArgumentError, "Namespace #{@ns[:pending]} has not been defined"
            end
            @ns = nil
          end

          insert(node, &block)
        end
      end

      private
      ###
      # Insert +node+ as a child of the current Node
      def insert(node, &block)
        node = @parent.add_child(node)
        if block_given?
          old_parent = @parent
          @parent    = node
          @arity ||= block.arity
          if @arity <= 0
            instance_eval(&block)
          else
            block.call(self)
          end
          @parent = old_parent
        end
        NodeBuilder.new(node, self)
      end

      class NodeBuilder # :nodoc:
        def initialize node, doc_builder
          @node = node
          @doc_builder = doc_builder
        end

        def []= k, v
          @node[k] = v
        end

        def [] k
          @node[k]
        end

        def method_missing(method, *args, &block)
          opts = args.last.is_a?(Hash) ? args.pop : {}
          case method.to_s
          when /^(.*)!$/
            @node['id'] = $1
            @node.content = args.first if args.first
          when /^(.*)=/
            @node[$1] = args.first
          else
            @node['class'] =
              ((@node['class'] || '').split(/\s/) + [method.to_s]).join(' ')
            @node.content = args.first if args.first
          end

          # Assign any extra options
          opts.each do |k,v|
            @node[k.to_s] = ((@node[k.to_s] || '').split(/\s/) + [v]).join(' ')
          end

          if block_given?
            old_parent = @doc_builder.parent
            @doc_builder.parent = @node
            value = @doc_builder.instance_eval(&block)
            @doc_builder.parent = old_parent
            return value
          end
          self
        end
      end
    end
  end
end
