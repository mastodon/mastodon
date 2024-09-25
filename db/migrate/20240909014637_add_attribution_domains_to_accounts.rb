# frozen_string_literal: true

class AddAttributionDomainsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :attribution_domains, :string, array: true, default: []
  end
end
