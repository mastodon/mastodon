# frozen_string_literal: true

module StatusSafeReblogInsert
  extend ActiveSupport::Concern

  class_methods do
    # This is a hack to ensure that no reblogs of discarded statuses are created,
    # as this cannot be enforced through database constraints the same way we do
    # for reblogs of deleted statuses.
    #
    # To achieve this, we redefine the internal method responsible for issuing
    # the "INSERT" statement and replace the "INSERT INTO ... VALUES ..." query
    # with an "INSERT INTO ... SELECT ..." query with a "WHERE deleted_at IS NULL"
    # clause on the reblogged status to ensure consistency at the database level.
    #
    # Otherwise, the code is kept as close as possible to ActiveRecord::Persistence
    # code, and actually calls it if we are not handling a reblog.
    def _insert_record(values)
      return super unless values.is_a?(Hash) && values['reblog_of_id'].present?

      primary_key = self.primary_key
      primary_key_value = nil

      if primary_key
        primary_key_value = values[primary_key]

        if !primary_key_value && prefetch_primary_key?
          primary_key_value = next_sequence_value
          values[primary_key] = primary_key_value
        end
      end

      # The following line is where we differ from stock ActiveRecord implementation
      im = _compile_reblog_insert(values)

      # Since we are using SELECT instead of VALUES, a non-error `nil` return is possible.
      # For our purposes, it's equivalent to a foreign key constraint violation
      result = connection.insert(im, "#{self} Create", primary_key || false, primary_key_value)
      raise ActiveRecord::InvalidForeignKey, "(reblog_of_id)=(#{values['reblog_of_id']}) is not present in table \"statuses\"" if result.nil?

      result
    end

    def _compile_reblog_insert(values)
      # This is somewhat equivalent to the following code of ActiveRecord::Persistence:
      # `arel_table.compile_insert(_substitute_values(values))`
      # The main difference is that we use a `SELECT` instead of a `VALUES` clause,
      # which means we have to build the `SELECT` clause ourselves and do a bit more
      # manual work.

      # Instead of using Arel::InsertManager#values, we are going to use Arel::InsertManager#select
      im = Arel::InsertManager.new
      im.into(arel_table)

      binds = []
      reblog_bind = nil
      values.each do |name, value|
        attr = arel_table[name]
        bind = predicate_builder.build_bind_attribute(attr.name, value)

        im.columns << attr
        binds << bind

        reblog_bind = bind if name == 'reblog_of_id'
      end

      im.select(arel_table.where(arel_table[:id].eq(reblog_bind)).where(arel_table[:deleted_at].eq(nil)).project(*binds))

      im
    end
  end
end
