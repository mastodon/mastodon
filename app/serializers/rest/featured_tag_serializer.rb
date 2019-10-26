# frozen_string_literal: true

class REST::FeaturedTagSerializer < ActiveModel::Serializer
  attributes :id, :name, :statuses_count, :last_status_at

  def id
    object.id.to_s
  end
end
