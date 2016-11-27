# frozen_string_literal: true

class Message < ApplicationRecord
  include Paginable
  include Streamable

  belongs_to :account, inverse_of: :messages
  belongs_to :private_recipient, foreign_key: 'private_recipient_id', class_name: 'Account', optional: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, presence: true
  validates :private_recipient, presence: true
  validates :text, presence: true, length: { maximum: 500 }, if: proc { |s| s.local? && !s.reblog? }
  validates :text, presence: true, if: proc { |s| !s.local? && !s.reblog? }
end
