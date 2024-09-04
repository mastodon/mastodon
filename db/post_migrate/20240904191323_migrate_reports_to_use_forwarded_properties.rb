# frozen_string_literal: true

class MigrateReportsToUseForwardedProperties < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class Account < ApplicationRecord; end

  class Report < ApplicationRecord
    belongs_to :account

    with_options class_name: 'Account' do
      belongs_to :target_account
      belongs_to :forwarded_by, optional: true
    end
  end

  def up
    # We migrate each forwarded report to the new columns, as forwarded only
    # indicates that the report was sent to the target accounts' server, we use
    # that domain as the forwarded_to_domains value:
    Report.where(forwarded: true, forwarded_at: nil).find_each do |report|
      report.update({
        forwarded_at: report.created_at,
        forwarded_to_domains: [report.target_account.domain],
        forwarded_by_id: report.account.id,
      })
    end
  end

  def down
    Report.where(forwarded: true).update_all(forwarded_to_domains: [], forwarded_by_id: nil, forwarded_at: nil)
  end
end
