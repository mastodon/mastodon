# frozen_string_literal: true
# == Schema Information
#
# Table name: reports
#
#  status_ids                 :integer          default([]), not null, is an Array
#  comment                    :text             default(""), not null
#  action_taken               :boolean          default(FALSE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_id                 :integer          not null
#  action_taken_by_account_id :integer
#  id                         :integer          not null, primary key
#  target_account_id          :integer          not null
#

class Report < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'
  belongs_to :action_taken_by_account, class_name: 'Account'

  scope :unresolved, -> { where(action_taken: false) }
  scope :resolved,   -> { where(action_taken: true) }

  validates :comment, length: { maximum: 1000 }

  def statuses
    Status.where(id: status_ids).includes(:account, :media_attachments, :mentions)
  end

  def media_attachments
    MediaAttachment.where(status_id: status_ids)
  end
end
