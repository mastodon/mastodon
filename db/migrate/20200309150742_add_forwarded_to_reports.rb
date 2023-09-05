# frozen_string_literal: true

class AddForwardedToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :forwarded, :boolean
  end
end
