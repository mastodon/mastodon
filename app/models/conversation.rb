# frozen_string_literal: true
# == Schema Information
#
# Table name: conversations
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Conversation < ApplicationRecord
  has_many :statuses
end
