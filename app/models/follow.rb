# frozen_string_literal: true
# == Schema Information
#
# Table name: follows
#
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :integer          not null
#  id                :integer          not null, primary key
#  target_account_id :integer          not null
#

class Follow < ApplicationRecord
  include Paginable

  belongs_to :account, counter_cache: :following_count, required: true

  belongs_to :target_account,
             class_name: 'Account',
             counter_cache: :followers_count,
             required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }

  scope :recent, -> { reorder(id: :desc) }
end
