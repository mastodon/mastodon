# frozen_string_literal: true

class REST::Admin::AccountWarningPresetSerializer < ActiveModel::Serializer
  attributes :id, :text, :title, :created_at, :updated_at

  def id
    object.id.to_s
  end
end
