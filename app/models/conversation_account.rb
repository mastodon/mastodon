# == Schema Information
#
# Table name: conversation_accounts
#
#  id                      :bigint(8)        not null, primary key
#  account_id              :bigint(8)
#  conversation_id         :bigint(8)
#  participant_account_ids :bigint(8)        default([]), not null, is an Array
#  status_ids              :bigint(8)        default([]), not null, is an Array
#  last_status_id          :bigint(8)
#

class ConversationAccount < ApplicationRecord
  belongs_to :account
  belongs_to :conversation
  belongs_to :last_status, class_name: 'Status'

  def participant_account_ids=(arr)
    self[:participant_account_ids] = arr.sort
  end

  def participant_accounts
    [account] + Account.where(id: participant_account_ids)
  end
end
