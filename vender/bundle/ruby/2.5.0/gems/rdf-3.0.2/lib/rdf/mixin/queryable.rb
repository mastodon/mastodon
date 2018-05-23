module RDF
  ##
  # An RDF query mixin.
  #
  # Classes that include this module should implement a `#query_pattern` method that
  # yields {RDF::Statement RDF statements}. Classes may also implement an optimized
  # `#query_execute` method that yields {RDF::Statement RDF statements}.
  #
  # @see RDF::Graph
  # @see RDF::Repository
  module Queryable
    autoload :Enumerator, 'rdf/mixin/enumerator'
    include ::Enumerable

    ##
    # Queries `self` for RDF statements matching the given `pattern`.
    #
    # This method delegates to the protected {RDF::Queryable#query_pattern} method for the actual lower-level query pattern matching implementation.
    #
    # @example Querying for statements having a given predicate
    #     queryable.query([nil, RDF::Vocab::DOAP.developer, nil])
    #     queryable.query(predicate: RDF::Vocab::DOAP.developer) do |statement|
    #       puts statement.inspect
    #     end
    #
    # @example Querying for solutions from a BGP
    #     query = RDF::Query.new {pattern [:s, :p, :o]}
    #     queryable.query(query) do |solution|
    #       puts solution.inspect
    #     end
    #
    # @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    # @param  [Hash{Symbol => Object}] options ({})
    #   Any other options passed to {#query_pattern} or {#query_execute}
    # @yield  [statement]
    #   each matching statement
    # @yieldparam  [RDF::Statement, RDF::Query::Solution] statement
    #   Statement or Solution
    # @yieldreturn [void] ignored
    # @return [Enumerator<RDF::Statement>, RDF::Enumerable, Query::Solutions]
    #   Returns an enumerable of statements (may be an enumerator) or query solutions, if passed an {RDF::Query}
    # @see    RDF::Queryable#query_pattern
    # @note   Since 2.0, this may return an Enumerable or an Enumerator in addition to Solutions
    def query(pattern, **options, &block)
      raise TypeError, "#{self} is not readable" if respond_to?(:readable?) && !readable?

      case pattern
        # A basic graph pattern (BGP) query:
        when Query
          solutions = RDF::Query::Solutions.new
          block = lambda {|solution| solutions << solution} unless block_given?
          before_query(pattern) if respond_to?(:before_query)
          query_execute(pattern, options, &block)
          after_query(pattern) if respond_to?(:after_query)
          # Returns the solutions, not an enumerator
          solutions
 
        # A simple triple/quad pattern query:
        else
          pattern = Query::Pattern.from(pattern)
          before_query(pattern) if respond_to?(:before_query)
          enum = case
            # Blank triple/quad patterns are equivalent to iterating over
            # every statement, so as a minor optimization we'll just do that
            # directly instead of bothering with `#query_pattern`:
            when pattern.blank?
              if block_given?
                each(&block)
              else
                to_a.extend(Queryable)
              end

            # Constant triple/quad patterns are equivalent to looking up a
            # particular statement, so as a minor optimization we'll just do
            # that directly instead of bothering with `#query_pattern`:
            when pattern.constant?
              statement = Statement.from(pattern)
              if include?(statement)
                if block_given?
                  yield statement
                else
                  [statement]
                end
              end

            # Otherwise, we delegate to `#query_pattern`:
            else # pattern.variable?
              query_pattern(pattern, options, &block)
          end
          after_query(pattern) if respond_to?(:after_query)
          enum
      end
    end

    ##
    # Queries `self` using the given basic graph pattern (BGP) query,
    # yielding each matched solution to the given block.
    #
    # Since RDF.rb 0.3.0, repository implementations can override this
    # method in order to provide for storage-specific optimized graph
    # pattern query execution.
    #
    # @param  [RDF::Query] query
    #   the query to execute
    # @param  [Hash{Symbol => Object}] options ({})
    #   Any other options passed to `query.execute`
    # @yield  [solution]
    # @yieldparam  [RDF::Query::Solution] solution
    # @yieldreturn [void] ignored
    # @return [void] ignored
    # @see    RDF::Queryable#query
    # @see    RDF::Query#execute
    # @since  0.3.0
    def query_execute(query, **options, &block)
      # By default, we let RDF.rb's built-in `RDF::Query#execute` handle BGP
      # query execution by breaking down the query into its constituent
      # triple patterns and invoking `RDF::Query::Pattern#execute` on each
      # pattern.
      query.execute(self, options, &block)
    end
    protected :query_execute

    ##
    # Queries `self` for RDF statements matching the given `pattern`,
    # yielding each matched statement to the given block.
    #
    # Since RDF.rb 0.2.0, repository implementations should override this
    # method in order to provide for storage-specific optimized triple
    # pattern matching.
    #
    # @param  [RDF::Query::Pattern] pattern
    #   the query pattern to match
    # @param  [Hash{Symbol => Object}] options ({})
    #   Any other options
    # @yield  [statement]
    # @yieldparam  [RDF::Statement] statement
    # @yieldreturn [void] ignored
    # @return [void] ignored
    # @see    RDF::Queryable#query
    # @see    RDF::Query::Pattern#execute
    # @since  0.2.0
    def query_pattern(pattern, **options, &block)
      # By default, we let Ruby's built-in `Enumerable#grep` handle the
      # matching of statements by iterating over all statements and calling
      # `RDF::Query::Pattern#===` on each statement.
      # @see http://ruby-doc.org/core/classes/Enumerable.html#M003121
      grep(pattern, &block)
    end
    protected :query_pattern

    ##
    # Queries `self` for an RDF statement matching the given `pattern` and
    # returns that statement if found.
    #
    # Returns `nil` if no statements match `pattern`.
    #
    # @overload first
    #   @return [RDF::Statement]
    #
    # @overload first(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [RDF::Statement]
    #
    # @return [RDF::Statement]
    # @since  0.1.9
    def first(pattern = nil)
      if pattern
        query(pattern) do |statement|
          return statement
        end
      elsif respond_to?(:each_statement)
        each_statement do |statement|
          return statement
        end
      else
        return super()
      end
      nil
    end

    ##
    # Queries `self` for an RDF statement matching the given `pattern` and
    # returns the statement's subject term.
    #
    # Returns `nil` if no statements match `pattern`.
    #
    # @overload first_subject
    #   @return [RDF::Resource]
    #
    # @overload first_subject(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [RDF::Resource]
    # @since  0.1.9
    def first_subject(pattern = nil)
      __send__(*(pattern ? [:query, pattern] : [:each])) do |statement|
        return statement.subject
      end
      return nil
    end

    ##
    # Queries `self` for an RDF statement matching the given `pattern` and
    # returns the statement's predicate term.
    #
    # Returns `nil` if no statements match `pattern`.
    #
    # @overload first_predicate
    #   @return [RDF::URI]
    #
    # @overload first_predicate(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [RDF::URI]
    # @since  0.1.9
    def first_predicate(pattern = nil)
      __send__(*(pattern ? [:query, pattern] : [:each])) do |statement|
        return statement.predicate
      end
      return nil
    end

    ##
    # Queries `self` for an RDF statement matching the given `pattern` and
    # returns the statement's object term.
    #
    # Returns `nil` if no statements match `pattern`.
    #
    # @overload first_object
    #   @return [RDF::Term]
    #
    # @overload first_object(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [RDF::Term]
    # @since  0.1.9
    def first_object(pattern = nil)
      __send__(*(pattern ? [:query, pattern] : [:each])) do |statement|
        return statement.object
      end
      return nil
    end

    ##
    # Queries `self` for RDF statements matching the given `pattern` and
    # returns the first found object literal.
    #
    # Returns `nil` if no statements match `pattern` or if none of the found
    # statements have a literal as their object term.
    #
    # @overload first_literal
    #   @return [RDF::Literal]
    #
    # @overload first_literal(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [RDF::Literal]
    #
    # @return [RDF::Literal]
    # @since  0.1.9
    def first_literal(pattern = nil)
      __send__(*(pattern ? [:query, pattern] : [:each])) do |statement|
        return statement.object if statement.object.is_a?(RDF::Literal)
      end
      return nil
    end

    ##
    # Queries `self` for RDF statements matching the given `pattern` and
    # returns the value of the first found object literal.
    #
    # Returns `nil` if no statements match `pattern` or if none of the found
    # statements have a literal as their object term.
    #
    # @overload first_value
    #   @return [Object]
    #
    # @overload first_value(pattern)
    #   @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern
    #   @return [Object]
    # @since  0.1.9
    def first_value(pattern = nil)
      (literal = first_literal(pattern)) ? literal.value : nil
    end

    ##
    # @private
    # @param  [Symbol, #to_sym] method
    # @return [Enumerator<RDF::Statement, RDF::Query::Pattern>]
    # @see    Object#enum_for
    def enum_for(method = :each, *args)
      # Ensure that enumerators are, themselves, queryable
      this = self
      Queryable::Enumerator.new do |yielder|
        this.send(method, *args) {|*y| yielder << (y.length > 1 ? y : y.first)}
      end
    end
    alias_method :to_enum, :enum_for
  end # Queryable
end # RDF
