# frozen_string_literal: true

class AddApplicationToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :application_id, :bigint, null: true
    add_foreign_key :reports, :oauth_applications, column: :application_id, on_delete: :nullify, validate: false
  end
end
