# frozen_string_literal: true
# == Schema Information
#
# Table name: conversation_mutes
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  conversation_id :integer          not null
#

class ConversationMute < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :conversation, required: true
end
