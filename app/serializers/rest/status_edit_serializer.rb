# frozen_string_literal: true

class REST::StatusEditSerializer < ActiveModel::Serializer
  attributes :text, :spoiler_text, :media_attachments_changed,
             :created_at
end
