# frozen_string_literal: true

module AccountFinderConcern
  extend ActiveSupport::Concern

  class_methods do
    def find_local!(username)
      find_remote!(username, nil)
    end

    def find_remote!(username, domain)
      raise ActiveRecord::RecordNotFound if username.blank?
      where('lower(accounts.username) = ?', username.downcase).where(domain.nil? ? { domain: nil } : 'lower(accounts.domain) = ?', domain&.downcase).take!
    end

    def find_local(username)
      find_local!(username)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_remote(username, domain)
      find_remote!(username, domain)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
