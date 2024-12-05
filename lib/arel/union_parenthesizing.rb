# frozen_string_literal: true

# Fix an issue with `LIMIT` ocurring on the left side of a `UNION` causing syntax errors.
# See https://github.com/rails/rails/issues/40181

# The fix has been merged in ActiveRecord: https://github.com/rails/rails/pull/51549
# TODO: drop this when available in ActiveRecord

# rubocop:disable all -- This is a mostly vendored file

module Arel
  module Visitors
    class ToSql
      private

        def infix_value_with_paren(o, collector, value, suppress_parens = false)
          collector << "( " unless suppress_parens
          collector = if o.left.class == o.class
            infix_value_with_paren(o.left, collector, value, true)
          else
            select_parentheses o.left, collector, false # Changed from `visit o.left, collector`
          end
          collector << value
          collector = if o.right.class == o.class
            infix_value_with_paren(o.right, collector, value, true)
          else
            select_parentheses o.right, collector, false # Changed from `visit o.right, collector`
          end
          collector << " )" unless suppress_parens
          collector
        end

        def select_parentheses(o, collector, always_wrap_selects = true)
          if o.is_a?(Nodes::SelectStatement) && (always_wrap_selects || require_parentheses?(o))
            collector << "("
            visit o, collector
            collector << ")"
            collector
          else
            visit o, collector
          end
        end

        def require_parentheses?(o)
          !o.orders.empty? || o.limit || o.offset
        end
    end
  end
end

# rubocop:enable all
