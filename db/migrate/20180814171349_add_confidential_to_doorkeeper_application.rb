require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddConfidentialToDoorkeeperApplication < ActiveRecord::Migration[5.2]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    safety_assured do
      add_column_with_default(
        :oauth_applications,
        :confidential,
        :boolean,
        allow_null: false,
        default: true # maintaining backwards compatibility: require secrets
      )
    end
  end

  def down
    remove_column :oauth_applications, :confidential
  end
end
