# frozen_string_literal: true
# == Schema Information
#
# Table name: conversations
#
#  id         :integer          not null, primary key
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Conversation < ApplicationRecord
  validates :uri, uniqueness: true, if: :uri?

  has_many :statuses

  def local?
    uri.nil?
  end
end
