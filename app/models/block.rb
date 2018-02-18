# frozen_string_literal: true
# == Schema Information
#
# Table name: blocks
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :integer          not null
#  target_account_id :integer          not null
#

class Block < ApplicationRecord
  include Paginable
  include RelationshipCacheable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }

  after_commit :remove_blocking_cache

  private

  def remove_blocking_cache
    Rails.cache.delete("exclude_account_ids_for:#{account_id}")
    Rails.cache.delete("exclude_account_ids_for:#{target_account_id}")
  end
end
