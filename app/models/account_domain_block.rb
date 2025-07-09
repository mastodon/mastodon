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

  belongs_to :account
  validates :domain, presence: true, uniqueness: { scope: :account_id }, domain: true

  after_commit :invalidate_domain_blocking_cache
  after_commit :invalidate_follow_recommendations_cache

  private

  def invalidate_domain_blocking_cache
    Rails.cache.delete("exclude_domains_for:#{account_id}")
    Rails.cache.delete(['exclude_domains', account_id, domain])
  end

  def invalidate_follow_recommendations_cache
    Rails.cache.delete("follow_recommendations/#{account_id}")
  end
end
