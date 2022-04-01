class AddInstanceActor < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    validates :username, uniqueness: { scope: :domain, case_sensitive: false }
  end

  def up
    Account.create!(id: -99, actor_type: 'Application', locked: true, username: Rails.configuration.x.local_domain)
  end

  def down
    Account.find_by(id: -99, actor_type: 'Application').destroy!
  end
end
