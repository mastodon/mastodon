class IdsToBigints < ActiveRecord::Migration[5.1]
  def change
    # We want to change columns that are IDs or reference IDs, so we'll
    # pick those that are "id" or end in "_id".
    id_regex = /(\A|_)id\Z/

    tables.each do |table|
      id_cols = columns(table).select {|c| id_regex.match?(c.name) }
      id_cols.each do |column|
        # Make sure they're already using an integer, not something
        # else.
        next unless column.sql_type == 'integer'

        change_column table, column.name, :bigint
      end
    end
  end
end
