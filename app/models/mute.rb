# frozen_string_literal: true
# == Schema Information
#
# Table name: mutes
#
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :integer          not null
#  id                :integer          not null, primary key
#  target_account_id :integer          not null
#

class Mute < ApplicationRecord
  include Paginable

  belongs_to :account, required: true
  belongs_to :target_account, class_name: 'Account', required: true

  validates :account_id, uniqueness: { scope: :target_account_id }

  REMOVE_BLOCKING_CACHE = -> do
    remove_blocking_cache('exclude_account_ids_for', account_id)
  end

  include CacheRemovable
end
