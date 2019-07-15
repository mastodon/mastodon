class AddInstanceActor < ActiveRecord::Migration[5.2]
  def up
    Account.create!(id: -99, actor_type: 'Application', locked: true, username: Rails.configuration.x.local_domain)
  end

  def down
    Account.find_by(id: -99, actor_type: 'Application').destroy!
  end
end
