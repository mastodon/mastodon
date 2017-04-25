# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'
  belongs_to :action_taken_by_account, class_name: 'Account'

  scope :unresolved, -> { where(action_taken: false) }
  scope :resolved,   -> { where(action_taken: true) }

  def statuses
    Status.where(id: status_ids)
  end

  def media_attachments
    media_attachments = []
    statuses.each do |s|
      media_attachments.concat s.media_attachments
    end
    media_attachments
  end
end
