module Chewy
  class Query
    module Compose
    protected

      def _filtered_query(query, filter, options = {})
        query = {match_all: {}} if !query.present? && filter.present?

        if filter.present?
          filtered = if query.present?
            {query: {filtered: {
              query: query,
              filter: filter
            }}}
          else
            {query: {filtered: {
              filter: filter
            }}}
          end
          filtered[:query][:filtered][:strategy] = options[:strategy].to_s if options[:strategy].present?
          filtered
        elsif query.present?
          {query: query}
        else
          {}
        end
      end

      def _queries_join(queries, logic)
        queries = queries.compact

        if queries.many? || (queries.present? && logic == :must_not)
          case logic
          when :dis_max
            {dis_max: {queries: queries}}
          when :must, :should, :must_not
            {bool: {logic => queries}}
          else
            if logic.is_a?(Float)
              {dis_max: {queries: queries, tie_breaker: logic}}
            else
              {bool: {should: queries, minimum_should_match: logic}}
            end
          end
        else
          queries.first
        end
      end

      def _filters_join(filters, logic)
        filters = filters.compact

        if filters.many? || (filters.present? && logic == :must_not)
          case logic
          when :and, :or
            {logic => filters}
          when :must, :should, :must_not
            {bool: {logic => filters}}
          else
            {bool: {should: filters, minimum_should_match: logic}}
          end
        else
          filters.first
        end
      end
    end
  end
end
