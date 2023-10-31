# frozen_string_literal: true

class REST::MarkerSerializer < ActiveModel::Serializer
  # Please update `app/javascript/mastodon/api_types/markers.ts` when making changes to the attributes

  attributes :last_read_id, :version, :updated_at

  def last_read_id
    object.last_read_id.to_s
  end

  def version
    object.lock_version
  end
end
