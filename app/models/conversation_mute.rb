# frozen_string_literal: true
# == Schema Information
#
# Table name: conversation_mutes
#
#  id              :integer          not null, primary key
#  conversation_id :integer          not null
#  account_id      :integer          not null
#

class ConversationMute < ApplicationRecord
  belongs_to :account
  belongs_to :conversation
end
