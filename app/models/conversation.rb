# frozen_string_literal: true

# == Schema Information
#
# Table name: conversations
#
#  id         :bigint(8)        not null, primary key
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Conversation < ApplicationRecord
  validates :uri, uniqueness: true, if: :uri?

  has_many :statuses, dependent: nil

  def local?
    uri.nil?
  end

  def to_message_id
    "#{self.class.name.downcase}-#{id}.#{created_at.to_date}"
  end
end
