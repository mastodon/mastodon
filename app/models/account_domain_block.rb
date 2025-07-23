# frozen_string_literal: true

# == Schema Information
#
# Table name: account_domain_blocks
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#

class AccountDomainBlock < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include RecommendationMaintenance

  belongs_to :account
  validates :domain, presence: true, uniqueness: { scope: :account_id }, domain: true

  after_commit :invalidate_domain_blocking_cache

  private

  def invalidate_domain_blocking_cache
    Rails.cache.delete("exclude_domains_for:#{account_id}")
    Rails.cache.delete(['exclude_domains', account_id, domain])
  end
end
