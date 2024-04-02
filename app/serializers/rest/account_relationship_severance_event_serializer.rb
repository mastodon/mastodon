# frozen_string_literal: true

class REST::AccountRelationshipSeveranceEventSerializer < ActiveModel::Serializer
  attributes :id, :type, :purged, :target_name, :followers_count, :following_count, :created_at

  def id
    object.id.to_s
  end
end
