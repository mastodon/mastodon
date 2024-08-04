# frozen_string_literal: true

class REST::BlockSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :account_id, :target_account_id, :uri

  def id
    object.id.to_s
  end
end
