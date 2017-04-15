# frozen_string_literal: true

class Block < ApplicationRecord
  include Paginable

  belongs_to :account, required: true
  belongs_to :target_account, class_name: 'Account', required: true

  validates :account_id, uniqueness: { scope: :target_account_id }

  after_create :remove_blocking_cache
  after_destroy :remove_blocking_cache

  def remove_blocking_cache
    Rails.cache.delete("blocked_account_ids:#{account_id}")
    Rails.cache.delete("blocked_account_ids:#{target_account_id}")
  end
end
