# frozen_string_literal: true

class REST::MuteSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :hide_notifications,
             :account_id, :target_account_id, :expires_at

  def id
    object.id.to_s
  end
end
