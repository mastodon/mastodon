# frozen_string_literal: true

# Add support for writing recursive CTEs in ActiveRecord

# From Lorin Thwaits (https://github.com/lorint) as per comment:
# https://github.com/vlado/activerecord-cte/issues/16#issuecomment-1433043310

module ActiveRecord
  module QueryMethodsExtensions
    def with_recursive(as, anchor, recursive)
      @is_recursive = true
      common_table = Arel.sql(anchor.arel.union(:all, recursive.arel).to_sql)
      from(as).with(as => common_table)
    end

    private

    def build_with(arel)
      return if with_values.empty?

      with_statements = with_values.map do |with_value|
        raise ArgumentError, "Unsupported argument type: #{with_value} #{with_value.class}" unless with_value.is_a?(Hash)

        build_with_value_from_hash(with_value)
      end

      # Was:  arel.with(with_statements)
      @is_recursive ? arel.with(:recursive, with_statements) : arel.with(with_statements)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::QueryMethods.prepend(ActiveRecord::QueryMethodsExtensions)
end
