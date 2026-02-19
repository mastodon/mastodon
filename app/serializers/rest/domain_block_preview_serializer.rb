# frozen_string_literal: true

class REST::DomainBlockPreviewSerializer < ActiveModel::Serializer
  attributes :following_count, :followers_count
end
