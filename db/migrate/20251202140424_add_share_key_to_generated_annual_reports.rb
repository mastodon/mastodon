# frozen_string_literal: true

class AddShareKeyToGeneratedAnnualReports < ActiveRecord::Migration[8.0]
  def change
    add_column :generated_annual_reports, :share_key, :string
  end
end
