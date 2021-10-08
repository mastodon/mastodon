# frozen_string_literal: true

module ActiveRecord
  module Batches
    def pluck_each(*column_names)
      relation = self

      options = column_names.extract_options!

      flatten     = column_names.size == 1
      batch_limit = options[:batch_limit] || 1_000
      order       = options[:order] || :asc

      column_names.unshift(primary_key)

      relation = relation.reorder(batch_order(order)).limit(batch_limit)
      relation.skip_query_cache!

      batch_relation = relation

      loop do
        batch = batch_relation.pluck(*column_names)

        break if batch.empty?

        primary_key_offset = batch.last[0]

        batch.each do |record|
          if flatten
            yield record[1]
          else
            yield record[1..-1]
          end
        end

        break if batch.size < batch_limit

        batch_relation = relation.where(
          predicate_builder[primary_key, primary_key_offset, order == :desc ? :lt : :gt]
        )
      end
    end
  end
end
