# frozen_string_literal: true

class REST::MuteSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :account, :target_account, :created_at, :hide_notifications

  def account
    REST::AccountSerializer.new(object.account)
  end

  def target_account
    REST::AccountSerializer.new(object.target_account)
  end
end
