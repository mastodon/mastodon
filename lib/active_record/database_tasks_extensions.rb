# frozen_string_literal: true

require_relative '../mastodon/database'
require_relative '../mastodon/snowflake'

module ActiveRecord
  module Tasks
    module DatabaseTasks
      original_load_schema = instance_method(:load_schema)

      define_method(:load_schema) do |db_config, *args|
        Mastodon::Database.add_post_migrate_path_to_rails(force: true)

        ActiveRecord::Base.establish_connection(db_config)
        Mastodon::Snowflake.define_timestamp_id

        original_load_schema.bind_call(self, db_config, *args)

        Mastodon::Snowflake.ensure_id_sequences_exist
      end
    end
  end
end
