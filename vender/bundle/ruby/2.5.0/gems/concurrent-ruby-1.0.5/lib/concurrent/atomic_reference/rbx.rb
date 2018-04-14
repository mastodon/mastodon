require 'concurrent/atomic_reference/direct_update'
require 'concurrent/atomic_reference/numeric_cas_wrapper'

module Concurrent

  # @!macro atomic_reference
  #
  # @note Extends `Rubinius::AtomicReference` version adding aliases
  #   and numeric logic.
  #
  # @!visibility private
  # @!macro internal_implementation_note
  class RbxAtomicReference < Rubinius::AtomicReference
    alias _compare_and_set compare_and_set
    include Concurrent::AtomicDirectUpdate
    include Concurrent::AtomicNumericCompareAndSetWrapper

    alias_method :value, :get
    alias_method :value=, :set
    alias_method :swap, :get_and_set
  end
end
