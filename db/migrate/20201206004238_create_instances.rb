class CreateInstances < ActiveRecord::Migration[5.2]
  def change
    create_view :instances, materialized: true

    # To be able to refresh the view concurrently,
    # at least one unique index is required
    safety_assured { add_index :instances, :domain, unique: true }
  end
end
