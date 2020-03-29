# frozen_string_literal: true
# == Schema Information
#
# Table name: email_domain_blocks
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailDomainBlock < ApplicationRecord
  include DomainNormalizable

  validates :domain, presence: true, uniqueness: true, domain: true

  def self.block?(email)
    _, domain = email.split('@', 2)

    return true if domain.nil?

    begin
      domain = TagManager.instance.normalize_domain(domain)
    rescue Addressable::URI::InvalidURIError
      return true
    end

    where(domain: domain).exists?
  end
end
