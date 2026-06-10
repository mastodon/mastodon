# frozen_string_literal: true

class REST::BookmarkFolderSerializer < ActiveModel::Serializer
  attributes :id, :title

  def id
    object.id.to_s
  end
end
