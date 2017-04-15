# frozen_string_literal: true

class Mute < ApplicationRecord
  include Paginable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  after_create :remove_blocking_cache
  after_destroy :remove_blocking_cache

  def remove_blocking_cache
    Rails.cache.delete("blocked_account_ids:#{account_id}")
  end
end
