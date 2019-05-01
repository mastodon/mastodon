# frozen_string_literal: true

class REST::AnnouncementLinkSerializer < ActiveModel::Serializer
  attributes :url, :text
end

class REST::AnnouncementSerializer < ActiveModel::Serializer
  attributes :id, :body
  has_many :links, serializer: REST::AnnouncementLinkSerializer
end
