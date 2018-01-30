# frozen_string_literal: true

class REST::AnnouncementLinkSerializer < ActiveModel::Serializer
  attributes :url, :text
end
