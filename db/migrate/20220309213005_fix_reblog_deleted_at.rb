# frozen_string_literal: true

class FixReblogDeletedAt < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'UPDATE statuses s SET deleted_at = r.deleted_at FROM statuses r WHERE s.reblog_of_id = r.id AND r.deleted_at IS NOT NULL' }
  end

  def down; end
end
