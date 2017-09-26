# frozen_string_literal: true

class REST::MuteSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :target_account, :created_at, :hide_notifications

  def target_account
    REST::AccountSerializer.new(object.target_account)
  end
end
