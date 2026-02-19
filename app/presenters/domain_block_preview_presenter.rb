# frozen_string_literal: true

class DomainBlockPreviewPresenter < ActiveModelSerializers::Model
  attributes :followers_count, :following_count
end
