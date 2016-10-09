class DomainBlock < ApplicationRecord
  validates :domain, presence: true, uniqueness: true

  def self.blocked?(domain)
    where(domain: domain).exists?
  end
end
