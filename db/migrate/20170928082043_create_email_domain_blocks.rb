# frozen_string_literal: true

class CreateEmailDomainBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :email_domain_blocks do |t|
      t.string :domain, null: false

      t.timestamps
    end
  end
end
