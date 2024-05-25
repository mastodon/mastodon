# frozen_string_literal: true

# == Schema Information
#
# Table name: one_time_keys
#
#  id         :bigint(8)        not null, primary key
#  device_id  :bigint(8)
#  key_id     :string           default(""), not null
#  key        :text             default(""), not null
#  signature  :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OneTimeKey < ApplicationRecord
  belongs_to :device

  validates :key_id, :key, :signature, presence: true
  validates :key, ed25519_key: true
  validates :signature, ed25519_signature: { message: :key, verify_key: ->(one_time_key) { one_time_key.device.fingerprint_key } }
end
