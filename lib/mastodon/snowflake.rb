# frozen_string_literal: true

module Mastodon::Snowflake
  DEFAULT_REGEX = /timestamp_id\('(?<seq_prefix>\w+)'/

  class Callbacks
    def self.around_create(record)
      now = Time.now.utc

      if record.created_at.nil? || record.created_at >= now || record.created_at == record.updated_at || record.override_timestamps
        yield
      else
        record.id = Mastodon::Snowflake.id_at(record.created_at)
        tries     = 0

        begin
          yield
        rescue ActiveRecord::RecordNotUnique
          raise if tries > 100

          tries     += 1
          record.id += rand(100)

          retry
        end
      end
    end
  end

  class << self
    # Our ID will be composed of the following:
    # 6 bytes (48 bits) of millisecond-level timestamp
    # 2 bytes (16 bits) of sequence data
    #
    # The 'sequence data' is intended to be unique within a
    # given millisecond, yet obscure the 'serial number' of
    # this row.
    #
    # To do this, we hash the following data:
    # * Table name (if provided, skipped if not)
    # * Secret salt (should not be guessable)
    # * Timestamp (again, millisecond-level granularity)
    #
    # We then take the first two bytes of that value, and add
    # the lowest two bytes of the table ID sequence number
    # (`table_name`_id_seq). This means that even if we insert
    # two rows at the same millisecond, they will have
    # distinct 'sequence data' portions.
    #
    # If this happens, and an attacker can see both such IDs,
    # they can determine which of the two entries was inserted
    # first, but not the total number of entries in the table
    # (even mod 2**16).
    #
    # The table name is included in the hash to ensure that
    # different tables derive separate sequence bases so rows
    # inserted in the same millisecond in different tables do
    # not reveal the table ID sequence number for one another.
    #
    # The secret salt is included in the hash to ensure that
    # external users cannot derive the sequence base given the
    # timestamp and table name, which would allow them to
    # compute the table ID sequence number.
    def define_timestamp_id
      return if already_defined?

      connection.execute(<<~SQL)
        CREATE OR REPLACE FUNCTION timestamp_id(table_name text)
        RETURNS bigint AS
        $$
          DECLARE
            time_part bigint;
            sequence_base bigint;
            tail bigint;
          BEGIN
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
      SQL
    end

    def ensure_id_sequences_exist
      # Find tables using timestamp IDs.
      connection.tables.each do |table|
        # We're only concerned with "id" columns.
        next unless (id_col = connection.columns(table).find { |col| col.name == 'id' })

        # And only those that are using timestamp_id.
        next unless (data = DEFAULT_REGEX.match(id_col.default_function))

        seq_name = data[:seq_prefix] + '_id_seq'

        # If we were on Postgres 9.5+, we could do CREATE SEQUENCE IF
        # NOT EXISTS, but we can't depend on that. Instead, catch the
        # possible exception and ignore it.
        # Note that seq_name isn't a column name, but it's a
        # relation, like a column, and follows the same quoting rules
        # in Postgres.
        connection.execute(<<~SQL)
          DO $$
            BEGIN
              CREATE SEQUENCE #{connection.quote_column_name(seq_name)};
            EXCEPTION WHEN duplicate_table THEN
              -- Do nothing, we have the sequence already.
            END
          $$ LANGUAGE plpgsql;
        SQL
      end
    end

    def id_at(timestamp, with_random: true)
      id  = timestamp.to_i * 1000
      id += rand(1000) if with_random
      id  = id << 16
      id += rand(2**16) if with_random
      id
    end

    private

    def already_defined?
      connection.execute(<<~SQL).values.first.first
        SELECT EXISTS(
          SELECT * FROM pg_proc WHERE proname = 'timestamp_id'
        );
      SQL
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end
