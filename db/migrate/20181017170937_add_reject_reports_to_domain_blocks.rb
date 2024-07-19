# frozen_string_literal: true

class AddRejectReportsToDomainBlocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :domain_blocks, :reject_reports, :boolean, default: false, null: false
    end
  end

  def down
    remove_column :domain_blocks, :reject_reports
  end
end
