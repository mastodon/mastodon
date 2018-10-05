# frozen_string_literal: true

# == Schema Information
#
# Table name: account_conversations
#
#  id                      :bigint(8)        not null, primary key
#  account_id              :bigint(8)
#  conversation_id         :bigint(8)
#  participant_account_ids :bigint(8)        default([]), not null, is an Array
#  status_ids              :bigint(8)        default([]), not null, is an Array
#  last_status_id          :bigint(8)
#


class AccountConversation < ApplicationRecord
  after_commit :push_to_streaming_api

  belongs_to :account
  belongs_to :conversation
  belongs_to :last_status, class_name: 'Status'

  def participant_account_ids=(arr)
    self[:participant_account_ids] = arr.sort
  end

  def participant_accounts
    if participant_account_ids.empty?
      [account]
    else
      Account.where(id: participant_account_ids)
    end
  end

  class << self
    def paginate_by_id(limit, options = {})
      if options[:min_id]
        paginate_by_min_id(limit, options[:min_id]).reverse
      else
        paginate_by_max_id(limit, options[:max_id], options[:since_id])
      end
    end

    def paginate_by_min_id(limit, min_id = nil)
      query = order(arel_table[:last_status_id].asc).limit(limit)
      query = query.where(arel_table[:last_status_id].gt(min_id)) if min_id.present?
      query
    end

    def paginate_by_max_id(limit, max_id = nil, since_id = nil)
      query = order(arel_table[:last_status_id].desc).limit(limit)
      query = query.where(arel_table[:last_status_id].lt(max_id)) if max_id.present?
      query = query.where(arel_table[:last_status_id].gt(since_id)) if since_id.present?
      query
    end

    def add_status(recipient, status)
      conversation = find_or_initialize_by(account: recipient, conversation_id: status.conversation_id, participant_account_ids: participants_from_status(recipient, status))
      conversation.status_ids << conversation.last_status_id if conversation.last_status_id.present?
      conversation.last_status = status
      conversation.save
      conversation
    end

    def remove_status(recipient, status)
      conversation = find_by(account: recipient, conversation_id: status.conversation_id, participant_account_ids: participants_from_status(recipient, status))

      return if conversation.nil? || conversation.last_status_id != status.id

      while (last_status_id = conversation.status_ids.pop)
        last_status = Status.find_by(id: last_status_id)
        break if last_status
      end

      if last_status.nil? && last_status_id.nil?
        conversation.destroy
      else
        conversation.last_status = last_status
        conversation.save
      end

      conversation
    end

    private

    def participants_from_status(recipient, status)
      ((status.mentions.pluck(:account_id) + [status.account_id]).uniq - [recipient.id]).sort
    end
  end

  private

  def push_to_streaming_api
    return unless subscribed_to_timeline?

    if destroyed?
      # Redis.current.publish(streaming_channel, Oj.dump(event: :delete, payload: id, queued_at: (Time.now.to_f * 1000.0).to_i))
    else
      PushConversationWorker.perform_async(id)
    end
  end

  def subscribed_to_timeline?
    Redis.current.exists("subscribed:#{streaming_channel}")
  end

  def streaming_channel
    "timeline:direct:#{account_id}"
  end
end
