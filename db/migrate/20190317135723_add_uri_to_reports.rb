# frozen_string_literal: true

class AddUriToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :uri, :string
  end
end
