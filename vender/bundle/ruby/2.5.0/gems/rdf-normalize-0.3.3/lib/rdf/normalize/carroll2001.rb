module RDF::Normalize
  class Carroll2001
    include RDF::Enumerable
    include Base
    include Utils

    ##
    # Create an enumerable with grounded nodes
    #
    # @param [RDF::Enumerable] enumerable
    # @return [RDF::Enumerable]
    def initialize(enumerable, options)
      @dataset = enumerable
    end

    def each(&block)
      ground_statements, anon_statements = [], []
      dataset.each_statement do |statement|
        (statement.has_blank_nodes? ? anon_statements : ground_statements) << statement
      end

      nodes = anon_statements.map(&:to_quad).flatten.compact.select(&:node?).uniq

      # Create a hash signature of every node, based on the signature of
      # statements it exists in.  
      # We also save hashes of nodes that cannot be reliably known; we will use
      # that information to eliminate possible recursion combinations.
      # 
      # Any mappings given in the method parameters are considered grounded.
      hashes, ungrounded_hashes = hash_nodes(anon_statements, nodes, {})

      # FIXME: likely need to iterate until hashes and ungrounded_hashes are the same size
      while hashes.size != ungrounded_hashes.size
        raise "Not done"
      end

      # Enumerate all statements, replacing nodes with new ground nodes using the hash as an identifier
      ground_statements.each(&block)
      anon_statements.each do |statement|
        quad = statement.to_quad.compact.map do |term|
          term.node? ? RDF::Node.intern(hashes[term]) : term
        end
        block.call RDF::Statement.from(quad)
      end
    end

  private

    # Given a set of statements, create a mapping of node => SHA1 for a given
    # set of blank nodes. 
    #
    # Returns a tuple of hashes:  one of grounded hashes, and one of all
    # hashes.  grounded hashes are based on non-blank nodes and grounded blank
    # nodes, and can be used to determine if a node's signature matches
    # another.
    #
    # @param [Array] statements 
    # @param [Array] nodes
    # @param [Hash] grounded_hashes
    #   mapping of node => SHA1 pairs as input, used to create more specific signatures of other nodes.
    # @private
    # @return [Hash, Hash]
    def hash_nodes(statements, nodes, grounded_hashes)
      hashes = grounded_hashes.dup
      ungrounded_hashes = {}
      hash_needed = true

      # We may have to go over the list multiple times.  If a node is marked as
      # grounded, other nodes can then use it to decide their own state of
      # grounded.
      while hash_needed
        starting_grounded_nodes = hashes.size
        nodes.each do | node |
          unless hashes.member? node
            grounded, hash = node_hash_for(node, statements, hashes)
            if grounded
              hashes[node] = hash
            end
            ungrounded_hashes[node] = hash
          end
        end

        # after going over the list, any nodes with a unique hash can be marked
        # as grounded, even if we have not tied them back to a root yet.
        uniques = {}
        ungrounded_hashes.each do |node, hash|
          uniques[hash] = uniques.has_key?(hash) ? false : node
        end
        uniques.each do |hash, node|
          hashes[node] = hash if node
        end
        hash_needed = starting_grounded_nodes != hashes.size
      end
      [hashes, ungrounded_hashes]
    end

    # Generate a hash for a node based on the signature of the statements it
    # appears in.  Signatures consist of grounded elements in statements
    # associated with a node, that is, anything but an ungrounded anonymous
    # node.  Creating the hash is simply hashing a sorted list of each
    # statement's signature, which is itself a concatenation of the string form
    # of all grounded elements.
    #
    # Nodes other than the given node are considered grounded if they are a
    # member in the given hash.
    #
    # @param [RDF::Node] node
    # @param [Array<RDF::Statement>] statements
    # @param [Hash] hashes
    # @return [Boolean, String]
    #   a tuple consisting of grounded being true or false and the String for the hash
    def node_hash_for(node, statements, hashes)
      statement_signatures = []
      grounded = true
      statements.each do | statement |
        if statement.to_quad.include?(node)
          statement_signatures << hash_string_for(statement, hashes, node)
          statement.to_quad.compact.each do | resource |
            grounded = false unless grounded?(resource, hashes) || resource == node
          end
        end
      end
      # Note that we sort the signatures--without a canonical ordering, 
      # we might get different hashes for equivalent nodes.
      [grounded,Digest::SHA1.hexdigest(statement_signatures.sort.to_s)]
    end

    # Provide a string signature for the given statement, collecting
    # string signatures for grounded node elements.
    # @return [String]
    def hash_string_for(statement, hashes, node)
      statement.to_quad.map {|r| string_for_node(r, hashes, node)}.join("")
    end

    # Returns true if a given node is grounded
    # A node is groundd if it is not a blank node or it is included
    # in the given mapping of grounded nodes.
    # @return [Boolean]
    def grounded?(node, hashes)
      (!(node.node?)) || (hashes.member? node)
    end

    # Provides a string for the given node for use in a string signature
    # Non-anonymous nodes will return their string form.  Grounded anonymous
    # nodes will return their hashed form.
    # @return [String]
    def string_for_node(node, hashes, target)
      case
      when node.nil?
        ""
      when node == target
        "itself"
      when node.node? && hashes.member?(node)
        hashes[node]
      when node.node?
        "a blank node"
      # RDF.rb auto-boxing magic makes some literals the same when they
      # should not be; the ntriples serializer will take care of us
      when node.literal?
        node.class.name + RDF::NTriples.serialize(node)
      else
        node.to_s
      end
    end
  end
end