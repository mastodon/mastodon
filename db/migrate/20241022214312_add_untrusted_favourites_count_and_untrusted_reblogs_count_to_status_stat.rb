# frozen_string_literal: true

class AddUntrustedFavouritesCountAndUntrustedReblogsCountToStatusStat < ActiveRecord::Migration[7.1]
  def change
    add_column :status_stats, :untrusted_favourites_count, :bigint, null: true
    add_column :status_stats, :untrusted_reblogs_count, :bigint, null: true
  end
end
