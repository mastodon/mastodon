# frozen_string_literal: true

# == Schema Information
#
# Table name: encrypted_messages
#
#  id               :bigint(8)        not null, primary key
#  device_id        :bigint(8)
#  from_account_id  :bigint(8)
#  from_device_id   :string           default(""), not null
#  type             :integer          default(0), not null
#  body             :text             default(""), not null
#  digest           :text             default(""), not null
#  message_franking :text             default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class EncryptedMessage < ApplicationRecord
  self.inheritance_column = nil

  include Paginable
  include Redisable

  scope :up_to, ->(id) { where(arel_table[:id].lteq(id)) }

  belongs_to :device
  belongs_to :from_account, class_name: 'Account'

  around_create Mastodon::Snowflake::Callbacks

  after_commit :push_to_streaming_api

  private

  def push_to_streaming_api
    return if destroyed? || !subscribed_to_timeline?

    PushEncryptedMessageWorker.perform_async(id)
  end

  def subscribed_to_timeline?
    redis.exists?("subscribed:#{streaming_channel}")
  end

  def streaming_channel
    "timeline:#{device.account_id}:#{device.device_id}"
  end
end
