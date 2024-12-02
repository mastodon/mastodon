# frozen_string_literal: true

# This file is copied almost entirely from GitLab, which has done a large
# amount of work to ensure that migrations can happen with minimal downtime.
# Many thanks to those engineers.

# Changes have been made to remove dependencies on other GitLab files and to
# shorten temporary column names.

# Documentation on using these functions (and why one might do so):
# https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/doc/development/database/avoiding_downtime_in_migrations.md

# The original file (since updated):
# https://gitlab.com/gitlab-org/gitlab-foss/-/blob/master/lib/gitlab/database/migration_helpers.rb

# It is licensed as follows:

# Copyright (c) 2011-present GitLab B.V.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This is bad form, but there are enough differences that it's impractical to do
# otherwise:

module Mastodon
  module MigrationHelpers
    class CorruptionError < StandardError
      attr_reader :index_name

      def initialize(index_name)
        @index_name = index_name

        super "The index `#{index_name}` seems to be corrupted, it contains duplicate rows. " \
          'For information on how to fix this, see our documentation: ' \
          'https://docs.joinmastodon.org/admin/troubleshooting/index-corruption/'
      end

      def cause
        nil
      end

      def backtrace
        []
      end
    end

    # Model that can be used for querying permissions of a SQL user.
    class Grant < ActiveRecord::Base
      self.table_name = 'information_schema.role_table_grants'

      def self.scope_to_current_user
        where('grantee = user')
      end

      # Returns true if the current user can create and execute triggers on the
      # given table.
      def self.create_and_execute_trigger?(table)
        priv = where(privilege_type: 'TRIGGER', table_name: table)

        priv.scope_to_current_user.any?
      end
    end

    # Gets an estimated number of rows for a table
    def estimate_rows_in_table(table_name)
      exec_query('SELECT reltuples FROM pg_class WHERE relname = ' +
        "'#{table_name}'").to_a.first['reltuples']
    end

    # Creates a new index, concurrently when supported
    #
    # On PostgreSQL this method creates an index concurrently, on MySQL this
    # creates a regular index.
    #
    # Example:
    #
    #     add_concurrent_index :users, :some_column
    #
    # See Rails' `add_index` for more info on the available arguments.
    def add_concurrent_index(table_name, column_name, **options)
      if transaction_open?
        raise 'add_concurrent_index can not be run inside a transaction, ' \
          'you can disable transactions by calling disable_ddl_transaction! ' \
          'in the body of your migration class'
      end

      options = options.merge({ algorithm: :concurrently })
      disable_statement_timeout

      add_index(table_name, column_name, **options)
    end

    # Removes an existed index, concurrently when supported
    #
    # On PostgreSQL this method removes an index concurrently.
    #
    # Example:
    #
    #     remove_concurrent_index :users, :some_column
    #
    # See Rails' `remove_index` for more info on the available arguments.
    def remove_concurrent_index(table_name, column_name, **options)
      if transaction_open?
        raise 'remove_concurrent_index can not be run inside a transaction, ' \
          'you can disable transactions by calling disable_ddl_transaction! ' \
          'in the body of your migration class'
      end

      options = options.merge({ algorithm: :concurrently })
      disable_statement_timeout

      remove_index(table_name, **options.merge({ column: column_name }))
    end

    # Removes an existing index, concurrently when supported
    #
    # On PostgreSQL this method removes an index concurrently.
    #
    # Example:
    #
    #     remove_concurrent_index :users, "index_X_by_Y"
    #
    # See Rails' `remove_index` for more info on the available arguments.
    def remove_concurrent_index_by_name(table_name, index_name, **options)
      if transaction_open?
        raise 'remove_concurrent_index_by_name can not be run inside a transaction, ' \
          'you can disable transactions by calling disable_ddl_transaction! ' \
          'in the body of your migration class'
      end

      options = options.merge({ algorithm: :concurrently })
      disable_statement_timeout

      remove_index(table_name, **options.merge({ name: index_name }))
    end

    # Adds a foreign key with only minimal locking on the tables involved.
    #
    # This method only requires minimal locking when using PostgreSQL. When
    # using MySQL this method will use Rails' default `add_foreign_key`.
    #
    # source - The source table containing the foreign key.
    # target - The target table the key points to.
    # column - The name of the column to create the foreign key on.
    # on_delete - The action to perform when associated data is removed,
    #             defaults to "CASCADE".
    def add_concurrent_foreign_key(source, target, column:, on_delete: :cascade, target_col: 'id')
      # Transactions would result in ALTER TABLE locks being held for the
      # duration of the transaction, defeating the purpose of this method.
      if transaction_open?
        raise 'add_concurrent_foreign_key can not be run inside a transaction'
      end

      # While MySQL does allow disabling of foreign keys it has no equivalent
      # of PostgreSQL's "VALIDATE CONSTRAINT". As a result we'll just fall
      # back to the normal foreign key procedure.
      on_delete = 'SET NULL' if on_delete == :nullify

      disable_statement_timeout

      key_name = concurrent_foreign_key_name(source, column, target_col)

      # Using NOT VALID allows us to create a key without immediately
      # validating it. This means we keep the ALTER TABLE lock only for a
      # short period of time. The key _is_ enforced for any newly created
      # data.
      execute <<-EOF.strip_heredoc
      ALTER TABLE #{source}
      ADD CONSTRAINT #{key_name}
      FOREIGN KEY (#{column})
      REFERENCES #{target} (#{target_col})
      #{on_delete ? "ON DELETE #{on_delete.upcase}" : ''}
      NOT VALID;
      EOF

      # Validate the existing constraint. This can potentially take a very
      # long time to complete, but fortunately does not lock the source table
      # while running.
      execute("ALTER TABLE #{source} VALIDATE CONSTRAINT #{key_name};")
    end

    # Returns the name for a concurrent foreign key.
    #
    # PostgreSQL constraint names have a limit of 63 bytes. The logic used
    # here is based on Rails' foreign_key_name() method, which unfortunately
    # is private so we can't rely on it directly.
    def concurrent_foreign_key_name(table, column, target_col)
      "fk_#{Digest::SHA256.hexdigest("#{table}_#{column}_#{target_col}_fk").first(10)}"
    end

    # Long-running migrations may take more than the timeout allowed by
    # the database. Disable the session's statement timeout to ensure
    # migrations don't get killed prematurely. (PostgreSQL only)
    def disable_statement_timeout
      execute('SET statement_timeout TO 0')
    end

    # Updates the value of a column in batches.
    #
    # This method updates the table in batches of 5% of the total row count.
    # This method will continue updating rows until no rows remain.
    #
    # When given a block this method will yield two values to the block:
    #
    # 1. An instance of `Arel::Table` for the table that is being updated.
    # 2. The query to run as an Arel object.
    #
    # By supplying a block one can add extra conditions to the queries being
    # executed. Note that the same block is used for _all_ queries.
    #
    # Example:
    #
    #     update_column_in_batches(:projects, :foo, 10) do |table, query|
    #       query.where(table[:some_column].eq('hello'))
    #     end
    #
    # This would result in this method updating only rows where
    # `projects.some_column` equals "hello".
    #
    # table - The name of the table.
    # column - The name of the column to update.
    # value - The value for the column.
    #
    # Rubocop's Metrics/AbcSize metric is disabled for this method as Rubocop
    # determines this method to be too complex while there's no way to make it
    # less "complex" without introducing extra methods (which actually will
    # make things _more_ complex).
    def update_column_in_batches(table_name, column, value)
      if transaction_open?
        raise 'update_column_in_batches can not be run inside a transaction, ' \
          'you can disable transactions by calling disable_ddl_transaction! ' \
          'in the body of your migration class'
      end

      table = Arel::Table.new(table_name)

      total = estimate_rows_in_table(table_name).to_i
      if total < 1
        count_arel = table.project(Arel.star.count.as('count'))
        count_arel = yield table, count_arel if block_given?

        total = exec_query(count_arel.to_sql).to_ary.first['count'].to_i

        return if total == 0
      end

      # Update in batches of 5% until we run out of any rows to update.
      batch_size = ((total / 100.0) * 5.0).ceil
      max_size = 1000

      # The upper limit is 1000 to ensure we don't lock too many rows. For
      # example, for "merge_requests" even 1% of the table is around 35 000
      # rows for GitLab.com.
      batch_size = max_size if batch_size > max_size

      start_arel = table.project(table[:id]).order(table[:id].asc).take(1)
      start_arel = yield table, start_arel if block_given?
      first_row = exec_query(start_arel.to_sql).to_ary.first
      # In case there are no rows but we didn't catch it in the estimated size:
      return unless first_row
      start_id = first_row['id'].to_i

      say "Migrating #{table_name}.#{column} (~#{total.to_i} rows)"

      started_time = Time.zone.now
      last_time = Time.zone.now
      migrated = 0
      loop do
        stop_row = nil

        suppress_messages do
          stop_arel = table.project(table[:id])
            .where(table[:id].gteq(start_id))
            .order(table[:id].asc)
            .take(1)
            .skip(batch_size)

          stop_arel = yield table, stop_arel if block_given?
          stop_row = exec_query(stop_arel.to_sql).to_ary.first

          update_arel = Arel::UpdateManager.new
            .table(table)
            .set([[table[column], value]])
            .where(table[:id].gteq(start_id))

          if stop_row
            stop_id = stop_row['id'].to_i
            start_id = stop_id
            update_arel = update_arel.where(table[:id].lt(stop_id))
          end

          update_arel = yield table, update_arel if block_given?

          execute(update_arel.to_sql)
        end

        migrated += batch_size
        if Time.zone.now - last_time > 1
          status = "Migrated #{migrated} rows"

          percentage = 100.0 * migrated / total
          status += " (~#{sprintf('%.2f', percentage)}%, "

          remaining_time = (100.0 - percentage) * (Time.zone.now - started_time) / percentage

          status += "#{(remaining_time / 60).to_i}:"
          status += sprintf('%02d', remaining_time.to_i % 60)
          status += ' remaining, '

          # Tell users not to interrupt if we're almost done.
          if remaining_time > 10
            status += 'safe to interrupt'
          else
            status += 'DO NOT interrupt'
          end

          status += ')'

          say status, true
          last_time = Time.zone.now
        end

        # There are no more rows left to update.
        break unless stop_row
      end
    end

    # Renames a column without requiring downtime.
    #
    # Concurrent renames work by using database triggers to ensure both the
    # old and new column are in sync. However, this method will _not_ remove
    # the triggers or the old column automatically; this needs to be done
    # manually in a post-deployment migration. This can be done using the
    # method `cleanup_concurrent_column_rename`.
    #
    # table - The name of the database table containing the column.
    # old - The old column name.
    # new - The new column name.
    # type - The type of the new column. If no type is given the old column's
    #        type is used.
    def rename_column_concurrently(table, old, new, type: nil)
      if transaction_open?
        raise 'rename_column_concurrently can not be run inside a transaction'
      end

      check_trigger_permissions!(table)
      trigger_name = rename_trigger_name(table, old, new)

      # If we were in the middle of update_column_in_batches, we should remove
      # the old column and start over, as we have no idea where we were.
      if column_for(table, new)
        remove_rename_triggers_for_postgresql(table, trigger_name)

        remove_column(table, new)
      end

      old_col = column_for(table, old)
      new_type = type || old_col.type

      col_opts = {
        precision: old_col.precision,
        scale: old_col.scale,
      }

      # We may be trying to reset the limit on an integer column type, so let
      # Rails handle that.
      unless [:bigint, :integer].include?(new_type)
        col_opts[:limit] = old_col.limit
      end

      add_column(table, new, new_type, **col_opts)

      # We set the default value _after_ adding the column so we don't end up
      # updating any existing data with the default value. This isn't
      # necessary since we copy over old values further down.
      change_column_default(table, new, old_col.default) if old_col.default

      quoted_table = quote_table_name(table)
      quoted_old = quote_column_name(old)
      quoted_new = quote_column_name(new)

      install_rename_triggers_for_postgresql(trigger_name, quoted_table,
                                             quoted_old, quoted_new)

      update_column_in_batches(table, new, Arel::Table.new(table)[old])

      change_column_null(table, new, false) unless old_col.null

      copy_indexes(table, old, new)
      copy_foreign_keys(table, old, new)
    end

    # Changes the type of a column concurrently.
    #
    # table - The table containing the column.
    # column - The name of the column to change.
    # new_type - The new column type.
    def change_column_type_concurrently(table, column, new_type)
      temp_column = rename_column_name(column)

      rename_column_concurrently(table, column, temp_column, type: new_type)

      # Primary keys don't necessarily have an associated index.
      if ActiveRecord::Base.get_primary_key(table) == column.to_s
        old_pk_index_name = "index_#{table}_on_#{column}"
        new_pk_index_name = "index_#{table}_on_#{column}_cm"

        unless indexes_for(table, column).find{|i| i.name == old_pk_index_name}
          add_concurrent_index(table, [temp_column],
            unique: true,
            name: new_pk_index_name
          )
        end
      end
    end

    # Performs cleanup of a concurrent type change.
    #
    # table - The table containing the column.
    # column - The name of the column to change.
    # new_type - The new column type.
    def cleanup_concurrent_column_type_change(table, column)
      temp_column = rename_column_name(column)

      # Wait for the indices to be built
      indexes_for(table, column).each do |index|
        expected_name = index.name + '_cm'

        puts "Waiting for index #{expected_name}"
        sleep 1 until indexes_for(table, temp_column).find {|i| i.name == expected_name }
      end

      was_primary = (ActiveRecord::Base.get_primary_key(table) == column.to_s)
      old_default_fn = column_for(table, column).default_function

      old_fks = []
      if was_primary
        # Get any foreign keys pointing at this column we need to recreate, and
        # remove the old ones.
        # Based on code from:
        # http://errorbank.blogspot.com/2011/03/list-all-foreign-keys-references-for.html
        old_fks_res = execute <<-EOF.strip_heredoc
          select m.relname as src_table,
            (select a.attname
              from pg_attribute a
              where a.attrelid = m.oid
                and a.attnum = o.conkey[1]
                and a.attisdropped = false) as src_col,
            o.conname as name,
            o.confdeltype as on_delete
          from pg_constraint o
          left join pg_class f on f.oid = o.confrelid
          left join pg_class c on c.oid = o.conrelid
          left join pg_class m on m.oid = o.conrelid
          where o.contype = 'f'
            and o.conrelid in (
              select oid from pg_class c where c.relkind = 'r')
            and f.relname = '#{table}';
          EOF
        old_fks = old_fks_res.to_a
        old_fks.each do |old_fk|
          add_concurrent_foreign_key(
            old_fk['src_table'],
            table,
            column: old_fk['src_col'],
            target_col: temp_column,
            on_delete: extract_foreign_key_action(old_fk['on_delete'])
          )

          remove_foreign_key(old_fk['src_table'], name: old_fk['name'])
        end
      end

      # If there was a sequence owned by the old column, make it owned by the
      # new column, as it will otherwise be deleted when we get rid of the
      # old column.
      if (seq_match = /^nextval\('([^']*)'(::text|::regclass)?\)/.match(old_default_fn))
        seq_name = seq_match[1]
        execute("ALTER SEQUENCE #{seq_name} OWNED BY #{table}.#{temp_column}")
      end

      transaction do
        # This has to be performed in a transaction as otherwise we might have
        # inconsistent data.

        cleanup_concurrent_column_rename(table, column, temp_column)
        rename_column(table, temp_column, column)

        # If there was an old default function, we didn't copy it. Do that now
        # in the transaction, so we don't miss anything.
        change_column_default(table, column, -> { old_default_fn }) if old_default_fn
      end

      # Rename any indices back to what they should be.
      indexes_for(table, column).each do |index|
        next unless index.name.end_with?('_cm')

        real_index_name = index.name.sub(/_cm$/, '')
        rename_index(table, index.name, real_index_name)
      end

      # Rename any foreign keys back to names based on the real column.
      foreign_keys_for(table, column).each do |fk|
        old_fk_name = concurrent_foreign_key_name(fk.from_table, temp_column, 'id')
        new_fk_name = concurrent_foreign_key_name(fk.from_table, column, 'id')
        execute("ALTER TABLE #{fk.from_table} RENAME CONSTRAINT " +
          "#{old_fk_name} TO #{new_fk_name}")
      end

      # Rename any foreign keys from other tables to names based on the real
      # column.
      old_fks.each do |old_fk|
        old_fk_name = concurrent_foreign_key_name(old_fk['src_table'],
          old_fk['src_col'], temp_column)
        new_fk_name = concurrent_foreign_key_name(old_fk['src_table'],
          old_fk['src_col'], column)
        execute("ALTER TABLE #{old_fk['src_table']} RENAME CONSTRAINT " +
          "#{old_fk_name} TO #{new_fk_name}")
      end

      # If the old column was a primary key, mark the new one as a primary key.
      if was_primary
        execute("ALTER TABLE #{table} ADD PRIMARY KEY USING INDEX " +
          "index_#{table}_on_#{column}")
      end
    end

    # Cleans up a concurrent column name.
    #
    # This method takes care of removing previously installed triggers as well
    # as removing the old column.
    #
    # table - The name of the database table.
    # old - The name of the old column.
    # new - The name of the new column.
    def cleanup_concurrent_column_rename(table, old, new)
      trigger_name = rename_trigger_name(table, old, new)

      check_trigger_permissions!(table)

      remove_rename_triggers_for_postgresql(table, trigger_name)

      remove_column(table, old)
    end

    # Performs a concurrent column rename when using PostgreSQL.
    def install_rename_triggers_for_postgresql(trigger, table, old, new)
      execute <<-EOF.strip_heredoc
      CREATE OR REPLACE FUNCTION #{trigger}()
      RETURNS trigger AS
      $BODY$
      BEGIN
        NEW.#{new} := NEW.#{old};
        RETURN NEW;
      END;
      $BODY$
      LANGUAGE 'plpgsql'
      VOLATILE
      EOF

      execute <<-EOF.strip_heredoc
      CREATE TRIGGER #{trigger}
      BEFORE INSERT OR UPDATE
      ON #{table}
      FOR EACH ROW
      EXECUTE PROCEDURE #{trigger}()
      EOF
    end

    # Installs the triggers necessary to perform a concurrent column rename on
    # MySQL.
    def install_rename_triggers_for_mysql(trigger, table, old, new)
      execute <<-EOF.strip_heredoc
      CREATE TRIGGER #{trigger}_insert
      BEFORE INSERT
      ON #{table}
      FOR EACH ROW
      SET NEW.#{new} = NEW.#{old}
      EOF

      execute <<-EOF.strip_heredoc
      CREATE TRIGGER #{trigger}_update
      BEFORE UPDATE
      ON #{table}
      FOR EACH ROW
      SET NEW.#{new} = NEW.#{old}
      EOF
    end

    # Removes the triggers used for renaming a PostgreSQL column concurrently.
    def remove_rename_triggers_for_postgresql(table, trigger)
      execute("DROP TRIGGER IF EXISTS #{trigger} ON #{table}")
      execute("DROP FUNCTION IF EXISTS #{trigger}()")
    end

    # Removes the triggers used for renaming a MySQL column concurrently.
    def remove_rename_triggers_for_mysql(trigger)
      execute("DROP TRIGGER IF EXISTS #{trigger}_insert")
      execute("DROP TRIGGER IF EXISTS #{trigger}_update")
    end

    # Returns the (base) name to use for triggers when renaming columns.
    def rename_trigger_name(table, old, new)
      'trigger_' + Digest::SHA256.hexdigest("#{table}_#{old}_#{new}").first(12)
    end

    # Returns the name to use for temporary rename columns.
    def rename_column_name(base)
      base.to_s + '_cm'
    end

    # Returns an Array containing the indexes for the given column
    def indexes_for(table, column)
      column = column.to_s

      indexes(table).select { |index| index.columns.include?(column) }
    end

    # Returns an Array containing the foreign keys for the given column.
    def foreign_keys_for(table, column)
      column = column.to_s

      foreign_keys(table).select { |fk| fk.column == column }
    end

    # Copies all indexes for the old column to a new column.
    #
    # table - The table containing the columns and indexes.
    # old - The old column.
    # new - The new column.
    def copy_indexes(table, old, new)
      old = old.to_s
      new = new.to_s

      indexes_for(table, old).each do |index|
        new_columns = index.columns.map do |column|
          column == old ? new : column
        end

        # This is necessary as we can't properly rename indexes such as
        # "ci_taggings_idx".
        name = index.name + '_cm'

        # If the order contained the old column, map it to the new one.
        order = index.orders
        if order.key?(old)
          order[new] = order.delete(old)
        end

        options = {
          unique: index.unique,
          name: name,
          length: index.lengths,
          order: order
        }

        # These options are not supported by MySQL, so we only add them if
        # they were previously set.
        options[:using] = index.using if index.using
        options[:where] = index.where if index.where

        add_concurrent_index(table, new_columns, **options)
      end
    end

    # Copies all foreign keys for the old column to the new column.
    #
    # table - The table containing the columns and indexes.
    # old - The old column.
    # new - The new column.
    def copy_foreign_keys(table, old, new)
      foreign_keys_for(table, old).each do |fk|
        add_concurrent_foreign_key(fk.from_table,
                                   fk.to_table,
                                   column: new,
                                   on_delete: fk.on_delete)
      end
    end

    # Returns the column for the given table and column name.
    def column_for(table, name)
      name = name.to_s

      columns(table).find { |column| column.name == name }
    end

    # Update the configuration of an index by creating a new one and then
    # removing the old one
    def update_index(table_name, index_name, columns, **index_options)
      if index_name_exists?(table_name, "#{index_name}_new") && index_name_exists?(table_name, index_name)
        remove_index table_name, name: "#{index_name}_new"
      elsif index_name_exists?(table_name, "#{index_name}_new")
        # Very unlikely case where the script has been interrupted during/after removal but before renaming
        rename_index table_name, "#{index_name}_new", index_name
      end

      begin
        add_index table_name, columns, **index_options.merge(name: "#{index_name}_new", algorithm: :concurrently)
      rescue ActiveRecord::RecordNotUnique
        remove_index table_name, name: "#{index_name}_new"
        raise CorruptionError.new(index_name)
      end

      remove_index table_name, name: index_name if index_name_exists?(table_name, index_name)
      rename_index table_name, "#{index_name}_new", index_name
    end

    def check_trigger_permissions!(table)
      unless Grant.create_and_execute_trigger?(table)
        dbname = ActiveRecord::Base.configurations[Rails.env]['database']
        user = ActiveRecord::Base.configurations[Rails.env]['username'] || ENV['USER']

        raise <<-EOF
Your database user is not allowed to create, drop, or execute triggers on the
table #{table}.

If you are using PostgreSQL you can solve this by logging in to the Mastodon
database (#{dbname}) using a super user and running:

    ALTER USER #{user} WITH SUPERUSER

The query will grant the user super user permissions, ensuring you don't run
into similar problems in the future (e.g. when new tables are created).
        EOF
      end
    end

    private

    # Private method copied from:
    # https://github.com/rails/rails/blob/v7.1.3.2/activerecord/lib/active_record/connection_adapters/postgresql/schema_statements.rb#L974-L980
    def extract_foreign_key_action(specifier)
      case specifier
      when 'c'; :cascade
      when 'n'; :nullify
      when 'r'; :restrict
      end
    end
  end
end
