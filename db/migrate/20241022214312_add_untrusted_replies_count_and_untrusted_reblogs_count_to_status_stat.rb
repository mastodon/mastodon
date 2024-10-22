# frozen_string_literal: true

class AddUntrustedRepliesCountAndUntrustedReblogsCountToStatusStat < ActiveRecord::Migration[7.1]
  def change
    add_column :status_stats, :untrusted_replies_count, :integer, null: true
    add_column :status_stats, :untrusted_reblogs_count, :integer, null: true
  end
end
