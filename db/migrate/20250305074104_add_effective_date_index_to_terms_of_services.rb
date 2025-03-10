# frozen_string_literal: true

class AddEffectiveDateIndexToTermsOfServices < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :terms_of_services, :effective_date, unique: true, algorithm: :concurrently, where: 'effective_date IS NOT NULL'
  end
end
