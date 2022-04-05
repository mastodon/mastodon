# frozen_string_literal: true
# == Schema Information
#
# Table name: conversations
#
#  id                :bigint(8)        not null, primary key
#  uri               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_status_id  :bigint(8)
#  parent_account_id :bigint(8)
#  inbox_url         :string
#

class Conversation < ApplicationRecord
  validates :uri, uniqueness: true, if: :uri?

  belongs_to :parent_status, class_name: 'Status', optional: true, inverse_of: :conversation
  belongs_to :parent_account, class_name: 'Account', optional: true

  has_many :statuses, inverse_of: :conversation

  scope :local, -> { where(uri: nil) }

  before_validation :set_parent_account, on: :create

  after_create :set_conversation_on_parent_status

  def local?
    uri.nil?
  end

  def object_type
    :conversation
  end

  private

  def set_parent_account
    self.parent_account = parent_status.account if parent_status.present?
  end

  def set_conversation_on_parent_status
    parent_status.update_column(:conversation_id, id) if parent_status.present?
  end
end
