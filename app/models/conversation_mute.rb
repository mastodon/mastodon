# frozen_string_literal: true
# == Schema Information
#
# Table name: conversation_mutes
#
#  conversation_id :bigint           not null
#  account_id      :bigint           not null
#  id              :bigint           not null, primary key
#

class ConversationMute < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :conversation, required: true
end
