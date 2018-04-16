# frozen_string_literal: true
module Rake

  ##
  # TaskArguments manage the arguments passed to a task.
  #
  class TaskArguments
    include Enumerable

    # Argument names
    attr_reader :names

    # Create a TaskArgument object with a list of argument +names+ and a set
    # of associated +values+.  +parent+ is the parent argument object.
    def initialize(names, values, parent=nil)
      @names = names
      @parent = parent
      @hash = {}
      @values = values
      names.each_with_index { |name, i|
        next if values[i].nil? || values[i] == ""
        @hash[name.to_sym] = values[i]
      }
    end

    # Retrieve the complete array of sequential values
    def to_a
      @values.dup
    end

    # Retrieve the list of values not associated with named arguments
    def extras
      @values[@names.length..-1] || []
    end

    # Create a new argument scope using the prerequisite argument
    # names.
    def new_scope(names)
      values = names.map { |n| self[n] }
      self.class.new(names, values + extras, self)
    end

    # Find an argument value by name or index.
    def [](index)
      lookup(index.to_sym)
    end

    # Specify a hash of default values for task arguments. Use the
    # defaults only if there is no specific value for the given
    # argument.
    def with_defaults(defaults)
      @hash = defaults.merge(@hash)
    end

    # Enumerates the arguments and their values
    def each(&block)
      @hash.each(&block)
    end

    # Extracts the argument values at +keys+
    def values_at(*keys)
      keys.map { |k| lookup(k) }
    end

    # Returns the value of the given argument via method_missing
    def method_missing(sym, *args)
      lookup(sym.to_sym)
    end

    # Returns a Hash of arguments and their values
    def to_hash
      @hash.dup
    end

    def to_s # :nodoc:
      inspect
    end

    def inspect # :nodoc:
      inspection = @hash.map do |k,v|
        "#{k.to_s}: #{v.to_s}"
      end.join(", ")

      "#<#{self.class} #{inspection}>"
    end

    # Returns true if +key+ is one of the arguments
    def has_key?(key)
      @hash.has_key?(key)
    end
    alias key? has_key?

    def fetch(*args, &block)
      @hash.fetch(*args, &block)
    end

    protected

    def lookup(name) # :nodoc:
      if @hash.has_key?(name)
        @hash[name]
      elsif @parent
        @parent.lookup(name)
      end
    end
  end

  EMPTY_TASK_ARGS = TaskArguments.new([], []) # :nodoc:
end
