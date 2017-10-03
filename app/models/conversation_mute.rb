# frozen_string_literal: true
# == Schema Information
#
# Table name: conversation_mutes
#
#  conversation_id :integer          not null
#  account_id      :integer          not null
#  id              :integer          not null, primary key
#

class ConversationMute < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :conversation, required: true
end
