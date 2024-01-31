# frozen_string_literal: true

class REST::ContextSerializer < REST::BaseSerializer
  has_many :ancestors,   serializer: REST::StatusSerializer
  has_many :descendants, serializer: REST::StatusSerializer
end
