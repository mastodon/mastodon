# frozen_string_literal: true

class AddTriggerForReblogsSoftDeleteScenario < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute(<<~SQL) # rubocop:disable Rails/SquishedSQLHeredocs
      CREATE OR REPLACE FUNCTION prevent_reblog_of_soft_deleted_status()
      RETURNS TRIGGER
      AS $$
      BEGIN
        IF EXISTS (
          SELECT
            1
          FROM
            statuses
          WHERE
            id = NEW.reblog_of_id
            AND deleted_at IS NOT NULL
        ) THEN
          NEW.id := NULL;
        END IF;

        RETURN NEW;
      END;
      $$
      LANGUAGE plpgsql;

      CREATE TRIGGER prevent_reblog_of_soft_deleted_status_trigger
        BEFORE INSERT ON statuses
        FOR EACH ROW
        WHEN (NEW.reblog_of_id IS NOT NULL)
        EXECUTE FUNCTION prevent_reblog_of_soft_deleted_status ();

    SQL
  end

  def down
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      DROP TRIGGER IF EXISTS prevent_reblog_of_soft_deleted_status_trigger
      ON statuses
    SQL
  end
end
