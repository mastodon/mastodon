# frozen_string_literal: true

class DomainBlock < ApplicationRecord
  enum severity: %i[silence suspend]

  validates :domain, presence: true, uniqueness: true

  def self.blocked?(domain)
    where(domain: domain, severity: :suspend).exists?
  end
end
