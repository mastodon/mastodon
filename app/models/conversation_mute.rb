# frozen_string_literal: true

class ConversationMute < ApplicationRecord
  belongs_to :account
  belongs_to :conversation
end
