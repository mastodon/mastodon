# frozen_string_literal: true

class Form::StatusBatch
  include ActiveModel::Model

  attr_accessor :status_ids, :action

  ACTION_TYPE = %w(nsfw_on nsfw_off delete).freeze

  def save
    case action
    when 'nsfw_on', 'nsfw_off'
      change_sensitive(action == 'nsfw_on')
    when 'delete'
      delete_statuses
    end
  end

  private

  def change_sensitive(sensitive)
    media_attached_status_ids = MediaAttachment.where(status_id: status_ids).pluck(:status_id)
    ApplicationRecord.transaction do
      Status.where(id: media_attached_status_ids).find_each do |status|
        status.update!(sensitive: sensitive)
      end
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def delete_statuses
    Status.where(id: status_ids).find_each do |status|
      RemovalWorker.perform_async(status.id)
    end
    true
  end
end
