# frozen_string_literal: true

module AccountFinderConcern
  extend ActiveSupport::Concern

  included do
    private_class_method :matching_username
    private_class_method :matching_domain
  end

  class_methods do
    def find_local!(username)
      find_local(username) || raise(ActiveRecord::RecordNotFound)
    end

    def find_remote!(username, domain)
      find_remote(username, domain) || raise(ActiveRecord::RecordNotFound)
    end

    def find_local(username)
      find_remote(username, nil)
    end

    def find_remote(username, domain)
      matching_username(username).merge(matching_domain(domain)).take
    end

    def matching_username(username)
      raise(ActiveRecord::RecordNotFound) if username.blank?
      where(arel_table[:username].lower.eq username.downcase)
    end

    def matching_domain(domain)
      if domain.nil?
        where(domain: nil)
      else
        where(arel_table[:domain].lower.eq domain.downcase)
      end
    end
  end
end
