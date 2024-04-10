# frozen_string_literal: true

# Add support for writing recursive CTEs in ActiveRecord

# Initially from Lorin Thwaits (https://github.com/lorint) as per comment:
# https://github.com/vlado/activerecord-cte/issues/16#issuecomment-1433043310

# Modified from the above code to change the signature to
# `with_recursive(hash)` and extending CTE hash values to also includes arrays
# of values that get turned into UNION ALL expressions.

# This implementation has been merged in Rails: https://github.com/rails/rails/pull/51601

module ActiveRecord
  module QueryMethodsExtensions
    def with_recursive(*args)
      @with_is_recursive = true
      check_if_method_has_arguments!(__callee__, args)
      spawn.with_recursive!(*args)
    end

    # Like #with_recursive but modifies the relation in place.
    def with_recursive!(*args) # :nodoc:
      self.with_values += args
      @with_is_recursive = true
      self
    end

    private

    def build_with(arel)
      return if with_values.empty?

      with_statements = with_values.map do |with_value|
        raise ArgumentError, "Unsupported argument type: #{with_value} #{with_value.class}" unless with_value.is_a?(Hash)

        build_with_value_from_hash(with_value)
      end

      # Was:  arel.with(with_statements)
      @with_is_recursive ? arel.with(:recursive, with_statements) : arel.with(with_statements)
    end

    def build_with_value_from_hash(hash)
      hash.map do |name, value|
        Arel::Nodes::TableAlias.new(build_with_expression_from_value(value), name)
      end
    end

    def build_with_expression_from_value(value)
      case value
      when Arel::Nodes::SqlLiteral then Arel::Nodes::Grouping.new(value)
      when ActiveRecord::Relation then value.arel
      when Arel::SelectManager then value
      when Array then value.map { |e| build_with_expression_from_value(e) }.reduce { |result, value| Arel::Nodes::UnionAll.new(result, value) }
      else
        raise ArgumentError, "Unsupported argument type: `#{value}` #{value.class}"
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::QueryMethods.prepend(ActiveRecord::QueryMethodsExtensions)
end
