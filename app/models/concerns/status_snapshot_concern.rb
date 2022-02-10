# frozen_string_literal: true

module StatusSnapshotConcern
  extend ActiveSupport::Concern

  included do
    has_many :edits, class_name: 'StatusEdit', inverse_of: :status, dependent: :destroy
  end

  def edited?
    edited_at.present?
  end

  def build_snapshot(account_id: nil, at_time: nil, rate_limit: true)
    # We don't use `edits#new` here to avoid it having saved when the
    # status is saved, since we want to control that manually

    StatusEdit.new(
      status_id: id,
      text: text,
      spoiler_text: spoiler_text,
      sensitive: sensitive,
      ordered_media_attachment_ids: ordered_media_attachment_ids&.dup || media_attachments.pluck(:id),
      media_descriptions: ordered_media_attachments.map(&:description),
      poll_options: preloadable_poll&.options&.dup,
      account_id: account_id || self.account_id,
      created_at: at_time || edited_at,
      rate_limit: rate_limit,
      content_type: content_type || 'text/plain',
      local_only: !!local_only
    )
  end

  def snapshot!(**options)
    build_snapshot(**options).save!
  end
end
