require 'chewy/query/nodes/base'
require 'chewy/query/nodes/expr'
require 'chewy/query/nodes/field'
require 'chewy/query/nodes/bool'
require 'chewy/query/nodes/and'
require 'chewy/query/nodes/or'
require 'chewy/query/nodes/not'
require 'chewy/query/nodes/raw'
require 'chewy/query/nodes/exists'
require 'chewy/query/nodes/missing'
require 'chewy/query/nodes/range'
require 'chewy/query/nodes/prefix'
require 'chewy/query/nodes/regexp'
require 'chewy/query/nodes/equal'
require 'chewy/query/nodes/query'
require 'chewy/query/nodes/script'
require 'chewy/query/nodes/has_child'
require 'chewy/query/nodes/has_parent'
require 'chewy/query/nodes/match_all'

module Chewy
  class Query
    # Context provides simplified DSL functionality for filters declaring.
    # You can use logic operations <tt>&</tt> and <tt>|</tt> to concat
    # expressions.
    #
    # @example
    #   UsersIndex.filter{ (article.title =~ /Honey/) & (age < 42) & !rate }
    #
    #
    class Filters
      def initialize(outer = nil, &block)
        @block = block
        @outer = outer || eval('self', block.binding, __FILE__, __LINE__)
      end

      # Outer scope call
      # Block evaluates in the external context
      #
      # @example
      #   def name
      #     'Friend'
      #   end
      #
      #   UsersIndex.filter{ name == o{ name } } # => {filter: {term: {name: 'Friend'}}}
      #
      def o(&block)
        @outer.instance_exec(&block)
      end

      # Returns field node
      # Used if method_missing is not working by some reason.
      # Additional expression options might be passed as second argument hash.
      #
      # @example
      #   UsersIndex.filter{ f(:name) == 'Name' } == UsersIndex.filter{ name == 'Name' } # => true
      #   UsersIndex.filter{ f(:name, execution: :bool) == ['Name1', 'Name2'] } ==
      #     UsersIndex.filter{ name(execution: :bool) == ['Name1', 'Name2'] } # => true
      #
      # Supports block for getting field name from the outer scope
      #
      # @example
      #   def field
      #     :name
      #   end
      #
      #   UsersIndex.filter{ f{ field } == 'Name' } == UsersIndex.filter{ name == 'Name' } # => true
      #
      def f(name = nil, *args, &block)
        name = block ? o(&block) : name
        Nodes::Field.new name, *args
      end

      # Returns script filter
      # Just script filter. Supports additional params.
      #
      # @example
      #   UsersIndex.filter{ s('doc["num1"].value > 1') }
      #   UsersIndex.filter{ s('doc["num1"].value > param1', param1: 42) }
      #
      # Supports block for getting script from the outer scope
      #
      # @example
      #   def script
      #     'doc["num1"].value > param1 || 1'
      #   end
      #
      #   UsersIndex.filter{ s{ script } } == UsersIndex.filter{ s('doc["num1"].value > 1') } # => true
      #   UsersIndex.filter{ s(param1: 42) { script } } == UsersIndex.filter{ s('doc["num1"].value > 1', param1: 42) } # => true
      #
      def s(*args, &block)
        params = args.extract_options!
        script = block ? o(&block) : args.first
        Nodes::Script.new script, params
      end

      # Returns query filter
      #
      # @example
      #   UsersIndex.filter{ q(query_string: {query: 'name: hello'}) }
      #
      # Supports block for getting query from the outer scope
      #
      # @example
      #   def query
      #     {query_string: {query: 'name: hello'}}
      #   end
      #
      #   UsersIndex.filter{ q{ query } } == UsersIndex.filter{ q(query_string: {query: 'name: hello'}) } # => true
      #
      def q(query = nil, &block)
        Nodes::Query.new block ? o(&block) : query
      end

      # Returns raw expression
      # Same as filter with arguments instead of block, but can participate in expressions
      #
      # @example
      #   UsersIndex.filter{ r(term: {name: 'Name'}) }
      #   UsersIndex.filter{ r(term: {name: 'Name'}) & (age < 42) }
      #
      # Supports block for getting raw filter from the outer scope
      #
      # @example
      #   def filter
      #     {term: {name: 'Name'}}
      #   end
      #
      #   UsersIndex.filter{ r{ filter } } == UsersIndex.filter{ r(term: {name: 'Name'}) } # => true
      #   UsersIndex.filter{ r{ filter } } == UsersIndex.filter(term: {name: 'Name'}) # => true
      #
      def r(raw = nil, &block)
        Nodes::Raw.new block ? o(&block) : raw
      end

      # Bool filter chainable methods
      # Used to create bool query. Nodes are passed as arguments.
      #
      # @example
      #   UsersIndex.filter{ must(age < 42, name == 'Name') }
      #   UsersIndex.filter{ should(age < 42, name == 'Name') }
      #   UsersIndex.filter{ must(age < 42).should(name == 'Name1', name == 'Name2') }
      #   UsersIndex.filter{ should_not(age >= 42).must(name == 'Name1') }
      #
      %w[must must_not should].each do |method|
        define_method method do |*exprs|
          Nodes::Bool.new.send(method, *exprs)
        end
      end

      # Initializes has_child filter.
      # Chainable interface acts the same as main query interface. You can pass plain
      # filters or plain queries or filter with DSL block.
      #
      # @example
      #   UsersIndex.filter{ has_child('user').filter(term: {role: 'Admin'}) }
      #   UsersIndex.filter{ has_child('user').filter{ role == 'Admin' } }
      #   UsersIndex.filter{ has_child('user').query(match: {name: 'borogoves'}) }
      #
      # Filters and queries might be combined and filter_mode and query_mode are configurable:
      #
      # @example
      #   UsersIndex.filter do
      #     has_child('user')
      #       .filter{ name: 'Peter' }
      #       .query(match: {name: 'Peter'})
      #       .filter{ age > 42 }
      #       .filter_mode(:or)
      #   end
      #
      def has_child(type) # rubocop:disable Naming/PredicateName
        Nodes::HasChild.new(type, @outer)
      end

      # Initializes has_parent filter.
      # Chainable interface acts the same as main query interface. You can pass plain
      # filters or plain queries or filter with DSL block.
      #
      # @example
      #   UsersIndex.filter{ has_parent('user').filter(term: {role: 'Admin'}) }
      #   UsersIndex.filter{ has_parent('user').filter{ role == 'Admin' } }
      #   UsersIndex.filter{ has_parent('user').query(match: {name: 'borogoves'}) }
      #
      # Filters and queries might be combined and filter_mode and query_mode are configurable:
      #
      # @example
      #   UsersIndex.filter do
      #     has_parent('user')
      #       .filter{ name: 'Peter' }
      #       .query(match: {name: 'Peter'})
      #       .filter{ age > 42 }
      #       .filter_mode(:or)
      #   end
      #
      def has_parent(type) # rubocop:disable Naming/PredicateName
        Nodes::HasParent.new(type, @outer)
      end

      # Just simple match_all filter.
      #
      def match_all
        Nodes::MatchAll.new
      end

      # Creates field or exists node
      # Additional options for further expression might be passed as hash
      #
      # @example
      #   UsersIndex.filter{ name == 'Name' } == UsersIndex.filter(term: {name: 'Name'}) # => true
      #   UsersIndex.filter{ name? } == UsersIndex.filter(exists: {term: 'name'}) # => true
      #   UsersIndex.filter{ name(execution: :bool) == ['Name1', 'Name2'] } ==
      #     UsersIndex.filter(terms: {name: ['Name1', 'Name2'], execution: :bool}) # => true
      #
      # Also field names might be chained to use dot-notation for ES field names
      #
      # @example
      #   UsersIndex.filter{ article.title =~ 'Hello' }
      #   UsersIndex.filter{ article.tags? }
      #
      def method_missing(method, *args) # rubocop:disable Style/MethodMissing
        method = method.to_s
        if method =~ /\?\Z/
          Nodes::Exists.new method.gsub(/\?\Z/, '')
        else
          f method, *args
        end
      end

      # Evaluates context block, returns top node.
      # For internal usage.
      #
      def __result__
        instance_exec(&@block)
      end

      # Renders evaluated filters.
      # For internal usage.
      #
      def __render__
        __result__.__render__ # haha, wtf?
      end
    end
  end
end
