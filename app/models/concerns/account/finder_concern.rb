# frozen_string_literal: true

module Account::FinderConcern
  extend ActiveSupport::Concern

  class_methods do
    def find_local!(username)
      find_local(username) || raise(ActiveRecord::RecordNotFound)
    end

    def find_remote!(username, domain)
      find_remote(username, domain) || raise(ActiveRecord::RecordNotFound)
    end

    def representative
      Account.find(Account::INSTANCE_ACTOR_ID).tap do |actor|
        actor.ensure_keys!
        actor.update!(username: Account::INSTANCE_ACTOR_USERNAME) if actor.username.include?(':')
      end
    rescue ActiveRecord::RecordNotFound
      Account.create!(id: Account::INSTANCE_ACTOR_ID, actor_type: 'Application', locked: true, username: Account::INSTANCE_ACTOR_USERNAME)
    end

    def find_local(username)
      find_remote(username, nil)
    end

    def find_remote(username, domain)
      Account
        .with_username(username)
        .with_domain(domain)
        .order(id: :asc)
        .take
    end
  end
end
