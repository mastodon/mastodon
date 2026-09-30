# frozen_string_literal: true

class CreateFaspCapabilities < ActiveRecord::Migration[8.1]
  def up
    create_table :fasp_capabilities do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.boolean :enabled, null: false, default: false
      t.references :fasp_provider, null: false, foreign_key: true

      t.timestamps
    end

    add_index :fasp_capabilities, [:fasp_provider_id, :name, :version], unique: true

    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO fasp_capabilities (fasp_provider_id, name, version, enabled, created_at, updated_at)
          SELECT fasp_providers.id AS fasp_provider_id, capabilities.value ->> 'id' AS name, capabilities.value ->> 'version' AS version, COALESCE((capabilities.value -> 'enabled')::boolean, false) AS enabled, fasp_providers.updated_at AS created_at, fasp_providers.updated_at AS updated_at
          FROM fasp_providers, jsonb_array_elements(fasp_providers.capabilities) AS capabilities;
      SQL

      remove_column :fasp_providers, :capabilities
    end
  end

  def down
    add_column :fasp_providers, :capabilities, :jsonb, default: [], null: false

    safety_assured do
      execute(<<~SQL.squish)
        UPDATE fasp_providers SET capabilities = aggregated_capabilities.capabilities_jsonb
        FROM (
          SELECT fasp_provider_id, jsonb_agg(jsonb_build_object('id', fasp_capabilities.name::text, 'version', fasp_capabilities.version, 'enabled', fasp_capabilities.enabled)) AS capabilities_jsonb
          FROM fasp_capabilities
          GROUP BY fasp_capabilities.fasp_provider_id
        ) AS aggregated_capabilities
        WHERE aggregated_capabilities.fasp_provider_id = fasp_providers.id
      SQL
    end

    remove_index :fasp_capabilities, [:fasp_provider_id, :name, :version], unique: true
    drop_table :fasp_capabilities
  end
end
