module RDF
  ##
  # A transaction application mixin.
  # 
  # Classes that include this module must provide a `#begin_transaction` method
  # returning an {RDF::Transaction}.
  #
  # @example running a read/write transaction with block syntax
  #   repository = RDF::Repository.new # or other transactable
  #
  #   repository.transaction(mutable: true) do |tx|
  #     tx.insert [:node, RDF.type, RDF::OWL.Thing]
  #     # ...
  #   end
  #
  # @see RDF::Transaction
  # @since 2.0.0
  module Transactable
    ##
    # Executes the given block in a transaction.
    #
    # @example running a transaction
    #   repository.transaction(mutable: true) do |tx|
    #     tx.insert [RDF::URI("http://rubygems.org/gems/rdf"), RDF::RDFS.label, "RDF.rb"]
    #   end
    #
    # Raising an error within the transaction block causes automatic rollback.
    #
    # @example manipulating a live transaction
    #   tx = repository.transaction(mutable: true)
    #   tx.insert [RDF::URI("http://rubygems.org/gems/rdf"), RDF::RDFS.label, "RDF.rb"]
    #   tx.execute
    #
    # @overload transaction(mutable: false)
    #   @param mutable [Boolean]
    #   @return [RDF::Transaction] an open transaction; the client is 
    #     responsible for closing the transaction via #execute or #rollback
    #
    # @overload transaction(mutable: false, &block)
    #   @param mutable [Boolean] 
    #     allows changes to the transaction, otherwise it is a read-only 
    #     snapshot of the underlying repository.
    #   @yield  [tx]
    #   @yieldparam  [RDF::Transaction] tx
    #   @yieldreturn [void] ignored
    #   @return [self]
    #
    # @see    RDF::Transaction
    # @since  0.3.0
    def transaction(mutable: false, &block)
      tx = begin_transaction(mutable: mutable)
      return tx unless block_given?

      begin
        case block.arity
          when 1 then block.call(tx)
          else tx.instance_eval(&block)
        end
      rescue => error
        rollback_transaction(tx)
        raise error
      end
      commit_transaction(tx)
      self
    end
    alias_method :transact, :transaction

  protected

    ##
    # Begins a new transaction.
    #
    # Subclasses implementing transaction-capable storage adapters may wish
    # to override this method in order to begin a transaction against the
    # underlying storage.
    #
    # @param mutable [Boolean] Create a mutable or immutable transaction.
    # @param graph_name [Boolean] A default graph name for statements inserted
    #   or deleted (default: nil)
    # @return [RDF::Transaction]
    def begin_transaction(mutable: false, graph_name: nil)
      raise NotImplementedError
    end

    ##
    # Rolls back the given transaction.
    #
    # @param  [RDF::Transaction] tx
    # @return [void] ignored
    # @since  0.3.0
    def rollback_transaction(tx)
      tx.rollback
    end

    ##
    # Commits the given transaction.
    #
    # Subclasses implementing transaction-capable storage adapters may wish
    # to override this method in order to commit the given transaction to
    # the underlying storage.
    #
    # @param  [RDF::Transaction] tx
    # @return [void] ignored
    # @since  0.3.0
    def commit_transaction(tx)
      tx.execute
    end
  end
end
