# frozen_string_literal: true

# == Schema Information
#
# Table name: conversation_mutes
#
#  id              :bigint(8)        not null, primary key
#  conversation_id :bigint(8)        not null
#  account_id      :bigint(8)        not null
#

class ConversationMute < ApplicationRecord
  belongs_to :account
  belongs_to :conversation
end
