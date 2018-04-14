module RDF
  ##
  # Classes that include this module must implement the methods
  # `#insert_statement`, `#delete_statement` and `#each_statement`.
  #
  # @see RDF::Graph
  # @see RDF::Repository
  module Mutable
    extend  RDF::Util::Aliasing::LateBound
    include RDF::Readable
    include RDF::Writable

    ##
    # Returns `true` if `self` is mutable.
    #
    # @return [Boolean]
    # @see    #immutable?
    def mutable?
      writable?
    end

    ##
    # Returns `true` if `self` is immutable.
    #
    # @return [Boolean]
    # @see    #mutable?
    def immutable?
      !mutable?
    end

    ##
    # Loads RDF statements from the given file or URL into `self`.
    #
    # @param  [String, #to_s]          url
    # @param  [Hash{Symbol => Object}] options
    #   Options from {RDF::Reader.open}
    # @option options [RDF::Resource] :graph_name
    #   Set set graph name of each loaded statement
    # @return [void]
     def load(url, graph_name: nil, **options)
      raise TypeError.new("#{self} is immutable") if immutable?

      Reader.open(url, {base_uri: url}.merge(options)) do |reader|
        if graph_name
          statements = []
          reader.each_statement do |statement|
            statement.graph_name = graph_name
            statements << statement
          end
          insert_statements(statements)
          statements.size
        else
          insert_statements(reader)
          nil
        end
      end
    end

    alias_method :load!, :load

    ##
    # Inserts RDF data into `self`.
    #
    # @param  [RDF::Enumerable, RDF::Statement, #to_rdf] data
    # @raise  [TypeError] if `self` is immutable
    # @return [Mutable]
    # @see    RDF::Writable#<<
    def <<(data)
      raise TypeError.new("#{self} is immutable") if immutable?

      super # RDF::Writable#<<
    end

    ##
    # Inserts RDF statements into `self`.
    #
    # @note using splat argument syntax with excessive arguments provided
    # significantly affects performance. Use Enumerator form for large
    # numbers of statements.
    #
    # @overload insert(*statements)
    #   @param  [Array<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    #
    # @overload insert(statements)
    #   @param  [Enumerable<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    #
    # @see    RDF::Writable#insert
    def insert(*statements)
      raise TypeError.new("#{self} is immutable") if immutable?

      super # RDF::Writable#insert
    end

    ##
    # Updates RDF statements in `self`.
    #
    # `#update([subject, predicate, object])` is equivalent to
    # `#delete([subject, predicate, nil])` followed by
    # `#insert([subject, predicate, object])` unless `object` is `nil`.
    #
    # @note using splat argument syntax with excessive arguments provided
    # significantly affects performance. Use Enumerator form for large
    # numbers of statements.
    #
    # @overload update(*statements)
    #   @param  [Array<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    #
    # @overload update(statements)
    #   @param  [Enumerable<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    def update(*statements)
      raise TypeError.new("#{self} is immutable") if immutable?
      statements = statements[0] if statements.length == 1 && statements[0].is_a?(Enumerable)

      statements.each do |statement|
        if (statement = Statement.from(statement))
          if statement.has_object?
            delete_insert([[statement.subject, statement.predicate, nil]], [statement])
          else
            delete([statement.subject, statement.predicate, nil])
          end
        end
      end
    end

    alias_method :update!, :update

    ##
    # Deletes RDF statements from `self`.
    # If any statement contains a {Query::Variable}, it is
    # considered to be a pattern, and used to query
    # self to find matching statements to delete.
    #
    # @note using splat argument syntax with excessive arguments provided
    # significantly affects performance. Use Enumerator form for large
    # numbers of statements.
    #
    # @overload delete(*statements)
    #   @param  [Array<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    #
    # @overload delete(statements)
    #   @param  [Enumerable<RDF::Statement>] statements
    #   @raise  [TypeError] if `self` is immutable
    #   @return [self]
    def delete(*statements)
      raise TypeError.new("#{self} is immutable") if immutable?

      statements.map! do |value|
        case
          when value.respond_to?(:each_statement)
            delete_statements(value)
            nil
          when (statement = Statement.from(value)).constant?
            statement
          else
            delete_statements(query(value))
            nil
        end
      end
      statements.compact!
      delete_statements(statements) unless statements.empty?

      return self
    end

    alias_method :delete!, :delete

    ##
    # Performs a set of deletes and inserts as a combined operation.
    #
    # @note in the base implementation, this is equivalent to calling `#delete` 
    #   and `#insert` sequentially. This method is preferred to take advantage 
    #   of (e.g.) `RDF::Repositories` that can execute the operation in a single
    #   request.
    #
    # @param  [Enumerable<RDF::Statement>, Array<RDF::Statement>] deletes
    # @param  [Enumerable<RDF::Statement>, Array<RDF::Statement>] inserts
    # @raise  [TypeError] if `self` is immutable
    # @return [Mutable] self
    #
    # @see #delete
    # @see #insert
    def delete_insert(deletes, inserts)
      deletes.respond_to?(:each_statement) ? delete(deletes) : delete(*deletes)
      inserts.respond_to?(:each_statement) ? insert(inserts) : insert(*inserts)

      self
    end

    alias_method :delete_insert!, :delete_insert

    ##
    # Applies the given changeset
    #
    # If `#supports?(:atomic_write)` is `true`, this must apply the changeset
    # atomically. Otherwise, it should offer an efficient implementation of a 
    # combined delete/insert of the changeset.
    #
    # @param changeset [RDF::Changeset] the changeset to apply
    # @return [Boolean] true if the changeset has been applied
    def apply_changeset(changeset)
      delete_insert(changeset.deletes, changeset.inserts)
    end

    ##
    # A readable & queryable snapshot of the repository for isolated reads. 
    # 
    # This method must be implemented when `#supports(:snapshots)` is `true`.
    # 
    # @return [Dataset] an immutable Dataset containing a current snapshot of
    #   the Repository contents.
    # @raise [NotImplementederror] when snapshots aren't implemented for the
    #   class
    def snapshot
      raise NotImplementedError, "#{self.class} does not implement snapshots"
    end

    ##
    # Deletes all RDF statements from `self`.
    #
    # @raise  [TypeError] if `self` is immutable
    # @return [Mutable]
    def clear
      raise TypeError.new("#{self} is immutable") if immutable?

      if respond_to?(:clear_statements, true)
        clear_statements
      else
        delete_statements(self)
      end

      return self
    end

    alias_method :clear!, :clear

    ##
    # @overload #from_reader
    #   Implements #from_reader for each available instance of {RDF::Reader},
    #   based on the reader symbol.
    #
    #   Arguments are passed to Reader.new.
    #  
    #   @return [String]
    #   @see {RDF::Reader.sym}
    def method_missing(meth, *args)
      reader = RDF::Reader.for(meth.to_s[5..-1].to_sym) if meth.to_s[0,5] == "from_"
      if reader
        self << reader.new(*args)
      else
        super
      end
    end

    ##
    # @note this instantiates an entire reader; it could probably be done more 
    #   efficiently by refactoring `RDF::Reader` and/or `RDF::Format` to expose
    #   a list of valid format symbols.
    def respond_to_missing?(name, include_private = false)
      return RDF::Reader.for(name.to_s[5..-1].to_sym) if name.to_s[0,5] == 'from_'
      super 
    end

  protected

    ##
    # Deletes the given RDF statements from the underlying storage.
    #
    # Defaults to invoking {RDF::Mutable#delete_statement} for each given statement.
    #
    # Subclasses of {RDF::Repository} may wish to override this method if
    # they are capable of more efficiently deleting multiple statements at
    # once.
    #
    # @param  [RDF::Enumerable] statements
    # @return [void]
    def delete_statements(statements)
      each = statements.respond_to?(:each_statement) ? :each_statement : :each
      statements.__send__(each) do |statement|
        delete_statement(statement)
      end
    end

    ##
    # Deletes an RDF statement from the underlying storage.
    #
    # Subclasses of {RDF::Repository} must implement this method, except if
    # they are immutable.
    #
    # @param  [RDF::Statement] statement
    # @return [void]
    # @abstract
    def delete_statement(statement)
      raise NotImplementedError.new("#{self.class}#delete_statement")
    end
  end
end
