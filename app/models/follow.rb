# frozen_string_literal: true

class Follow < ApplicationRecord
  include Paginable

  belongs_to :account, counter_cache: :following_count, required: true

  belongs_to :target_account,
             class_name: 'Account',
             counter_cache: :followers_count,
             required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }
end
