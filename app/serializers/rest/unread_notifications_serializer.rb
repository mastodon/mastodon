# frozen_string_literal: true

class REST::UnreadNotificationsSerializer < ActiveModel::Serializer
  attributes :count, :limit
end
