# frozen_string_literal: true

class FixInvalidDomainBlockSeverities < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE domain_blocks
        SET severity = CASE WHEN severity > 2 THEN 2 WHEN severity < 0 THEN 0 END
        WHERE severity > 2 OR severity < 0 RETURNING id;
      SQL
    end
  end

  def down; end
end
