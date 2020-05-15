# frozen_string_literal: true
# == Schema Information
#
# Table name: email_domain_blocks
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint(8)
#

class EmailDomainBlock < ApplicationRecord
  include DomainNormalizable

  belongs_to :parent, class_name: 'EmailDomainBlock', optional: true
  has_many :children, class_name: 'EmailDomainBlock', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  validates :domain, presence: true, uniqueness: true, domain: true

  def with_dns_records=(val)
    @with_dns_records = ActiveModel::Type::Boolean.new.cast(val)
  end

  def with_dns_records?
    @with_dns_records
  end

  alias with_dns_records with_dns_records?

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
