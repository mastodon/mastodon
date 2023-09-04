class AddSeverityToDomainBlocks < ActiveRecord::Migration[5.0]
  def change
    add_column :domain_blocks, :severity, :integer, default: 0
  end
end
