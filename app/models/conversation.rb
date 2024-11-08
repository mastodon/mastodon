# frozen_string_literal: true

class Conversation < ApplicationRecord
  validates :uri, uniqueness: true, if: :uri?

  has_many :statuses, dependent: nil

  def local?
    uri.nil?
  end
end
