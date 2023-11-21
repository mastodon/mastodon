# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_filter_accounts
#
#  id                :bigint(8)        not null, primary key
#  custom_filter_id  :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CustomFilterAccount < ApplicationRecord
  belongs_to :custom_filter
  belongs_to :target_account, class_name: 'Account'

  validates :target_account, uniqueness: { scope: :custom_filter }

  before_save :prepare_cache_invalidation!
  before_destroy :prepare_cache_invalidation!
  after_commit :invalidate_cache!

  private

  def prepare_cache_invalidation!
    custom_filter.prepare_cache_invalidation!
  end

  def invalidate_cache!
    custom_filter.invalidate_cache!
  end
end
