# frozen_string_literal: true

class AddIndexInstancesOnReverseDomain < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :instances, "reverse('.' || domain), domain", name: :index_instances_on_reverse_domain, algorithm: :concurrently
  end
end
