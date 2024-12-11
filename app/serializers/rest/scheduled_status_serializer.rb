# frozen_string_literal: true

class REST::ScheduledStatusSerializer < ActiveModel::Serializer
  attributes :id, :scheduled_at, :params

  has_many :media_attachments, serializer: REST::MediaAttachmentSerializer

  def id
    object.id.to_s
  end

  def params
    object.params.without('application_id')
  end
end
