# frozen_string_literal: true

class AddConfidentialToDoorkeeperApplication < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :oauth_applications,
        :confidential,
        :boolean,
        null: false,
        default: true # maintaining backwards compatibility: require secrets
      )
    end
  end

  def down
    remove_column :oauth_applications, :confidential
  end
end
