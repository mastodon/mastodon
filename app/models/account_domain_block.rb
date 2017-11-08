# frozen_string_literal: true
# == Schema Information
#
# Table name: account_domain_blocks
#
#  domain     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer
#  id         :integer          not null, primary key
#

class AccountDomainBlock < ApplicationRecord
  include Paginable

  belongs_to :account, required: true
  validates :domain, presence: true, uniqueness: { scope: :account_id }

  REMOVE_BLOCKING_CACHE = -> do
    remove_blocking_cache('exclude_domains_for', account_id)
  end

  include CacheRemovable
end
