# frozen_string_literal: true

class AddInstanceActor < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    validates :username, uniqueness: { scope: :domain, case_sensitive: false }

    INSTANCE_ACTOR_ID = -99

    before_create :generate_keys

    def generate_keys
      keypair = OpenSSL::PKey::RSA.new(2048)
      self.private_key = keypair.to_pem
      self.public_key  = keypair.public_key.to_pem
    end
  end

  def up
    Account.create!(id: Account::INSTANCE_ACTOR_ID, actor_type: 'Application', locked: true, username: Rails.configuration.x.local_domain)
  end

  def down
    Account.find_by(id: Account::INSTANCE_ACTOR_ID, actor_type: 'Application').destroy!
  end
end
