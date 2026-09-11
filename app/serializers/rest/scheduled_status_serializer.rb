# frozen_string_literal: true

class REST::ScheduledStatusSerializer < ActiveModel::Serializer
  attributes :id, :scheduled_at, :params

  has_many :media_attachments, serializer: REST::MediaAttachmentSerializer

  def id
    object.id.to_s
  end

  def params
    object.params.merge(
      quoted_status_id: object.params['quoted_status_id']&.to_s,
      quote_approval_policy: InteractionPolicy::POLICY_FLAGS.keys.find { |key| object.params['quote_approval_policy']&.anybits?(InteractionPolicy::POLICY_FLAGS[key] << 16) }&.to_s || 'nobody'
    )
  end
end
