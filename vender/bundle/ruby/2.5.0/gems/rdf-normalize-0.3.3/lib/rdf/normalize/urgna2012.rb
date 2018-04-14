module RDF::Normalize
  class URGNA2012 < URDNA2015

    def each(&block)
      ns = NormalizationState.new(@options)
      normalize_statements(ns, &block)
    end

    class NormalizationState < URDNA2015::NormalizationState
      protected

      # 2012 version uses SHA-1
      def hexdigest(val)
        Digest::SHA1.hexdigest(val)
      end

      # @param [RDF::Node] related
      # @param [RDF::Statement] statement
      # @param [IdentifierIssuer] issuer
      # @param [String] position one of :s, :o, or :g
      # @return [String] the SHA1 hexdigest hash
      def hash_related_node(related, statement, issuer, position)
        identifier = canonical_issuer.identifier(related) ||
                     issuer.identifier(related) ||
                     hash_first_degree_quads(related)
        input = position.to_s
        input << statement.predicate.to_s
        input << identifier
        log_debug("hrel") {"input: #{input.inspect}, hash: #{hexdigest(input)}"}
        hexdigest(input)
      end

      # In URGNA2012, the position parameter passed to the Hash Related Blank Node algorithm was instead modeled as a direction parameter, where it could have the value p, for property, when the related blank node was a `subject` and the value r, for reverse or reference, when the related blank node was an `object`. Since URGNA2012 only normalized graphs, not datasets, there was no use of the `graph` position.
      def hash_related_statement(identifier, statement, issuer, map)
        if statement.subject.node? && statement.subject != identifier
          hash = log_depth {hash_related_node(statement.subject, statement, issuer, :p)}
          map[hash] ||= []
          map[hash] << statement.subject unless map[hash].include?(statement.subject)
        elsif statement.object.node? && statement.object != identifier
          hash = log_depth {hash_related_node(statement.object, statement, issuer, :r)}
          map[hash] ||= []
          map[hash] << statement.object unless map[hash].include?(statement.object)
        end
      end
    end
  end
end