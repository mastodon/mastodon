# frozen_string_literal: true

module Status::SafeReblogInsert
  extend ActiveSupport::Concern

  class_methods do
    # This patch overwrites the built-in ActiveRecord `_insert_record` method to
    # ensure that no reblogs of discarded statuses are created, as this cannot be
    # enforced through DB constraints the same way as reblogs of deleted statuses
    #
    # We redefine the internal method responsible for issuing the `INSERT`
    # statement and replace the `INSERT INTO ... VALUES ...` query with an `INSERT
    # INTO ... SELECT ...` query with a `WHERE deleted_at IS NULL` clause on the
    # reblogged status to ensure consistency at the database level.
    #
    # The code is kept similar to ActiveRecord::Persistence code and calls it
    # directly when we are not handling a reblog.
    #
    # https://github.com/rails/rails/blob/v7.2.1.1/activerecord/lib/active_record/persistence.rb#L238-L263
    def _insert_record(connection, values, returning)
      return super unless values.is_a?(Hash) && values['reblog_of_id']&.value.present?

      primary_key = self.primary_key
      primary_key_value = nil

      if prefetch_primary_key? && primary_key
        values[primary_key] ||= begin
          primary_key_value = next_sequence_value
          _default_attributes[primary_key].with_cast_value(primary_key_value)
        end
      end

      # The following line departs from stock ActiveRecord
      # Original code was:
      # im = Arel::InsertManager.new(arel_table)
      # Instead, we use a custom builder when a reblog is happening:
      im = _compile_reblog_insert(values)

      with_connection do |_c|
        connection.insert(
          im, "#{self} Create", primary_key || false, primary_key_value,
          returning: returning
        ).tap do |result|
          # Since we are using SELECT instead of VALUES, a non-error `nil` return is possible.
          # For our purposes, it's equivalent to a foreign key constraint violation
          raise ActiveRecord::InvalidForeignKey, "(reblog_of_id)=(#{values['reblog_of_id'].value}) is not present in table \"statuses\"" if result.nil?
        end
      end
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
      values.each do |name, attribute|
        attr = arel_table[name]
        bind = predicate_builder.build_bind_attribute(attr.name, attribute.value)

        im.columns << attr
        binds << bind

        reblog_bind = bind if name == 'reblog_of_id'
      end

      im.select(arel_table.where(arel_table[:id].eq(reblog_bind)).where(arel_table[:deleted_at].eq(nil)).project(*binds))

      im
    end
  end
end
