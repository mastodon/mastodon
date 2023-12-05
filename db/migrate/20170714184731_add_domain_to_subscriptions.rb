# frozen_string_literal: true

class AddDomainToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :domain, :string
  end
end
