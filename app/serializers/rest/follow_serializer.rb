# frozen_string_literal: true

class REST::FollowSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :account_id,
             :target_account_id, :show_reblogs, :uri,
             :notify, :languages

  def id
    object.id.to_s
  end
end
