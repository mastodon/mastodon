# frozen_string_literal: true

class REST::SearchSerializer < REST::BaseSerializer
  has_many :accounts, serializer: REST::AccountSerializer
  has_many :statuses, serializer: REST::StatusSerializer
  has_many :hashtags, serializer: REST::TagSerializer
end
