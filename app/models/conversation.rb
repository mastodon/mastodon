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

  scope :local, -> { where(uri: nil) }

  def local?
    uri.nil?
  end

  def object_type
    :conversation
  end
end
