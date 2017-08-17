# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    desc 'Setup the db or migrate depending on state of db'
    task setup: :environment do
      begin
        if ActiveRecord::Migrator.current_version.zero?
          Rake::Task['db:migrate'].invoke
          Rake::Task['db:seed'].invoke
        end
      rescue ActiveRecord::NoDatabaseError
        Rake::Task['db:setup'].invoke
      else
        Rake::Task['db:migrate'].invoke
      end
    end
  end

  task :migrate do
    # We do this after every migration so we don't have to deal with
    # setting up timestamp_id as a default every time we create a
    # table, which would inevitably be forgotten at some point.
    Rake::Task['db:ensure_ids_are_timestamp_based'].execute
  end

  # Before we load the schema, define the timestamp_id function.
  # Idiomatically, we might do this in a migration, but then it
  # wouldn't end up in schema.rb, so we'd need to figure out a way to
  # get it in before doing db:setup as well. This is simpler, and
  # ensures it's always in place.
  Rake::Task['db:schema:load'].enhance ['db:define_timestamp_id']

  # After we load the schema, make sure we have sequences for each
  # table using IDs.
  Rake::Task['db:schema:load'].enhance do
    Rake::Task['db:ensure_id_sequences_exist'].invoke
  end

  task :define_timestamp_id do
    conn = ActiveRecord::Base.connection

    # Make sure we don't already have a `timestamp_id` function.
    unless conn.execute("SELECT EXISTS(
      SELECT * FROM pg_proc WHERE proname = 'timestamp_id'
      );").values.first.first
      # The function doesn't exist, so we'll define it.
      conn.execute("
        CREATE OR REPLACE FUNCTION timestamp_id(table_name text)
        RETURNS bigint AS
        $$
          DECLARE
            time_part bigint;
            sequence_base bigint;
            tail bigint;
          BEGIN
            -- Our ID will be composed of the following:
            -- 6 bytes (48 bits) of millisecond-level timestamp
            -- 2 bytes (16 bits) of sequence data

            -- The 'sequence data' is intended to be unique within a
            -- given millisecond, yet obscure the 'serial number' of
            -- this row.

            -- To do this, we hash the following data:
            -- * Table name (if provided, skipped if not)
            -- * Secret salt (should not be guessable)
            -- * Timestamp (again, millisecond-level granularity)

            -- We then take the first two bytes of that value, and add
            -- the lowest two bytes of the table ID sequence number
            -- (`table_name`_id_seq). This means that even if we insert
            -- two rows at the same millisecond, they will have
            -- distinct 'sequence data' portions.

            -- If this happens, and an attacker can see both such IDs,
            -- they can determine which of the two entries was inserted
            -- first, but not the total number of entries in the table
            -- (even mod 2**16).

            -- The table name is included in the hash to ensure that
            -- different tables derive separate sequence bases so rows
            -- inserted in the same millisecond in different tables do
            -- not reveal the table ID sequence number for one another.

            -- The secret salt is included in the hash to ensure that
            -- external users cannot derive the sequence base given the
            -- timestamp and table name, which would allow them to
            -- compute the table ID sequence number.

            time_part := (
              -- Get the time in milliseconds
              ((date_part('epoch', now()) * 1000))::bigint
              -- And shift it over two bytes
              << 16);

            sequence_base := (
              'x' ||
              -- Take the first two bytes (four hex characters)
              substr(
                -- Of the MD5 hash of the data we documented
                md5(table_name ||
                  '#{SecureRandom.hex(16)}' ||
                  time_part::text
                ),
                1, 4
              )
            -- And turn it into a bigint
            )::bit(16)::bigint;

            -- Finally, add our sequence number to our base, and chop
            -- it to the last two bytes
            tail := (
              (sequence_base + nextval(table_name || '_id_seq'))
              & 65535);

            -- Return the time part and the sequence part. OR appears
            -- faster here than addition, but they're equivalent:
            -- time_part has no trailing two bytes, and tail is only
            -- the last two bytes.
            RETURN time_part | tail;
          END
        $$ LANGUAGE plpgsql VOLATILE;
      ")
    end
  end

  task :ensure_ids_are_timestamp_based do
    conn = ActiveRecord::Base.connection

    # First, make sure we have a `timestamp_id` function.
    Rake::Task['db:define_timestamp_id'].execute

    # Now, see if there are any tables using sequential IDs.
    conn.tables.each do |table|
      # We're only concerned with "id" columns.
      next unless (id_col = conn.columns(table).find { |col| col.name == 'id' })

      # And only those that are still using serials.
      next unless id_col.serial?

      # Make sure they're using a bigint, not something else.
      if id_col.sql_type != 'bigint'
        raise "Table #{table} has an non-bigint ID column."
      end

      # Make them use our timestamp IDs instead.
      alter_query = "ALTER TABLE #{conn.quote_table_name(table)}
        ALTER COLUMN id
        SET DEFAULT timestamp_id(#{conn.quote(table)})"
      conn.execute(alter_query)
    end
  end

  task :ensure_id_sequences_exist do
    conn = ActiveRecord::Base.connection

    # First, make sure we have a `timestamp_id` function.
    Rake::Task['db:define_timestamp_id'].execute

    # Find tables using timestamp IDs.
    default_regex = /timestamp_id\('(?<seq_prefix>\w+)'/
    conn.tables.each do |table|
      # We're only concerned with "id" columns.
      next unless (id_col = conn.columns(table).find { |col| col.name == 'id' })

      # And only those that are using timestamp_id.
      next unless (data = default_regex.match(id_col.default_function))

      seq_name = data[:seq_prefix] + '_id_seq'
      # If we were on Postgres 9.5+, we could do CREATE SEQUENCE IF
      # NOT EXISTS, but we can't depend on that. Instead, catch the
      # possible exception and ignore it.
      # Note that seq_name isn't a column name, but it's a
      # relation, like a column, and follows the same quoting rules
      # in Postgres.
      seq_query = "DO $$
        BEGIN
          CREATE SEQUENCE #{conn.quote_column_name(seq_name)};
        EXCEPTION WHEN duplicate_table THEN
          -- Do nothing, we have the sequence already.
        END
      $$ LANGUAGE plpgsql;"
      conn.execute(seq_query)
    end
  end
end
