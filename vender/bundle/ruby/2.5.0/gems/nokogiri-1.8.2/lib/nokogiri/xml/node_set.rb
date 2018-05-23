module Nokogiri
  module XML
    ####
    # A NodeSet contains a list of Nokogiri::XML::Node objects.  Typically
    # a NodeSet is return as a result of searching a Document via
    # Nokogiri::XML::Searchable#css or Nokogiri::XML::Searchable#xpath
    class NodeSet
      include Nokogiri::XML::Searchable
      include Enumerable

      # The Document this NodeSet is associated with
      attr_accessor :document

      alias :clone :dup

      # Create a NodeSet with +document+ defaulting to +list+
      def initialize document, list = []
        @document = document
        document.decorate(self)
        list.each { |x| self << x }
        yield self if block_given?
      end

      ###
      # Get the first element of the NodeSet.
      def first n = nil
        return self[0] unless n
        list = []
        [n, length].min.times { |i| list << self[i] }
        list
      end

      ###
      # Get the last element of the NodeSet.
      def last
        self[-1]
      end

      ###
      # Is this NodeSet empty?
      def empty?
        length == 0
      end

      ###
      # Returns the index of the first node in self that is == to +node+. Returns nil if no match is found.
      def index(node)
        each_with_index { |member, j| return j if member == node }
        nil
      end

      ###
      # Insert +datum+ before the first Node in this NodeSet
      def before datum
        first.before datum
      end

      ###
      # Insert +datum+ after the last Node in this NodeSet
      def after datum
        last.after datum
      end

      alias :<< :push
      alias :remove :unlink

      ###
      # call-seq: css *rules, [namespace-bindings, custom-pseudo-class]
      #
      # Search this node set for CSS +rules+. +rules+ must be one or more CSS
      # selectors. For example:
      #
      # For more information see Nokogiri::XML::Searchable#css
      def css *args
        rules, handler, ns, _ = extract_params(args)
        paths = css_rules_to_xpath(rules, ns)

        inject(NodeSet.new(document)) do |set, node|
          set + xpath_internal(node, paths, handler, ns, nil)
        end
      end

      ###
      # call-seq: xpath *paths, [namespace-bindings, variable-bindings, custom-handler-class]
      #
      # Search this node set for XPath +paths+. +paths+ must be one or more XPath
      # queries.
      #
      # For more information see Nokogiri::XML::Searchable#xpath
      def xpath *args
        paths, handler, ns, binds = extract_params(args)

        inject(NodeSet.new(document)) do |set, node|
          set + xpath_internal(node, paths, handler, ns, binds)
        end
      end

      ###
      # Search this NodeSet's nodes' immediate children using CSS selector +selector+
      def > selector
        ns = document.root.namespaces
        xpath CSS.xpath_for(selector, :prefix => "./", :ns => ns).first
      end

      ###
      # call-seq: search *paths, [namespace-bindings, xpath-variable-bindings, custom-handler-class]
      #
      # Search this object for +paths+, and return only the first
      # result. +paths+ must be one or more XPath or CSS queries.
      #
      # See Searchable#search for more information.
      #
      # Or, if passed an integer, index into the NodeSet:
      #
      #   node_set.at(3) # same as node_set[3]
      #
      def at *args
        if args.length == 1 && args.first.is_a?(Numeric)
          return self[args.first]
        end

        super(*args)
      end
      alias :% :at

      ###
      # Filter this list for nodes that match +expr+
      def filter expr
        find_all { |node| node.matches?(expr) }
      end

      ###
      # Append the class attribute +name+ to all Node objects in the NodeSet.
      def add_class name
        each do |el|
          classes = el['class'].to_s.split(/\s+/)
          el['class'] = classes.push(name).uniq.join " "
        end
        self
      end

      ###
      # Remove the class attribute +name+ from all Node objects in the NodeSet.
      # If +name+ is nil, remove the class attribute from all Nodes in the
      # NodeSet.
      def remove_class name = nil
        each do |el|
          if name
            classes = el['class'].to_s.split(/\s+/)
            if classes.empty?
              el.delete 'class'
            else
              el['class'] = (classes - [name]).uniq.join " "
            end
          else
            el.delete "class"
          end
        end
        self
      end

      ###
      # Set the attribute +key+ to +value+ or the return value of +blk+
      # on all Node objects in the NodeSet.
      def attr key, value = nil, &blk
        unless Hash === key || key && (value || blk)
          return first.attribute(key)
        end

        hash = key.is_a?(Hash) ? key : { key => value }

        hash.each { |k,v| each { |el| el[k] = v || blk[el] } }

        self
      end
      alias :set :attr
      alias :attribute :attr

      ###
      # Remove the attributed named +name+ from all Node objects in the NodeSet
      def remove_attr name
        each { |el| el.delete name }
        self
      end

      ###
      # Iterate over each node, yielding  to +block+
      def each(&block)
        0.upto(length - 1) do |x|
          yield self[x]
        end
      end

      ###
      # Get the inner text of all contained Node objects
      #
      # Note: This joins the text of all Node objects in the NodeSet:
      #
      #    doc = Nokogiri::XML('<xml><a><d>foo</d><d>bar</d></a></xml>')
      #    doc.css('d').text # => "foobar"
      #
      # Instead, if you want to return the text of all nodes in the NodeSet:
      #
      #    doc.css('d').map(&:text) # => ["foo", "bar"]
      #
      # See Nokogiri::XML::Node#content for more information.
      def inner_text
        collect(&:inner_text).join('')
      end
      alias :text :inner_text

      ###
      # Get the inner html of all contained Node objects
      def inner_html *args
        collect{|j| j.inner_html(*args) }.join('')
      end

      ###
      # Wrap this NodeSet with +html+ or the results of the builder in +blk+
      def wrap(html, &blk)
        each do |j|
          new_parent = document.parse(html).first
          j.add_next_sibling(new_parent)
          new_parent.add_child(j)
        end
        self
      end

      ###
      # Convert this NodeSet to a string.
      def to_s
        map(&:to_s).join
      end

      ###
      # Convert this NodeSet to HTML
      def to_html *args
        if Nokogiri.jruby?
          options = args.first.is_a?(Hash) ? args.shift : {}
          if !options[:save_with]
            options[:save_with] = Node::SaveOptions::NO_DECLARATION | Node::SaveOptions::NO_EMPTY_TAGS | Node::SaveOptions::AS_HTML
          end
          args.insert(0, options)
        end
        map { |x| x.to_html(*args) }.join
      end

      ###
      # Convert this NodeSet to XHTML
      def to_xhtml *args
        map { |x| x.to_xhtml(*args) }.join
      end

      ###
      # Convert this NodeSet to XML
      def to_xml *args
        map { |x| x.to_xml(*args) }.join
      end

      alias :size :length
      alias :to_ary :to_a

      ###
      # Removes the last element from set and returns it, or +nil+ if
      # the set is empty
      def pop
        return nil if length == 0
        delete last
      end

      ###
      # Returns the first element of the NodeSet and removes it.  Returns
      # +nil+ if the set is empty.
      def shift
        return nil if length == 0
        delete first
      end

      ###
      # Equality -- Two NodeSets are equal if the contain the same number
      # of elements and if each element is equal to the corresponding
      # element in the other NodeSet
      def == other
        return false unless other.is_a?(Nokogiri::XML::NodeSet)
        return false unless length == other.length
        each_with_index do |node, i|
          return false unless node == other[i]
        end
        true
      end

      ###
      # Returns a new NodeSet containing all the children of all the nodes in
      # the NodeSet
      def children
        node_set = NodeSet.new(document)
        each do |node|
          node.children.each { |n| node_set.push(n) }
        end
        node_set
      end

      ###
      # Returns a new NodeSet containing all the nodes in the NodeSet
      # in reverse order
      def reverse
        node_set = NodeSet.new(document)
        (length - 1).downto(0) do |x|
          node_set.push self[x]
        end
        node_set
      end

      ###
      # Return a nicely formated string representation
      def inspect
        "[#{map(&:inspect).join ', '}]"
      end

      alias :+ :|

      # @private
      IMPLIED_XPATH_CONTEXTS = [ './/'.freeze, 'self::'.freeze ].freeze # :nodoc:

    end
  end
end
