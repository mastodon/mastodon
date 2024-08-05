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
      actor = Account.find(Account::INSTANCE_ACTOR_ID).tap(&:ensure_keys!)
      actor.update!(username: 'mastodon.internal') if actor.username.include?(':')
      actor
    rescue ActiveRecord::RecordNotFound
      Account.create!(id: Account::INSTANCE_ACTOR_ID, actor_type: 'Application', locked: true, username: 'mastodon.internal')
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
