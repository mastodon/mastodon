# frozen_string_literal: true

class REST::Admin::WebhookEventSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Account'
      REST::Admin::AccountSerializer
    when 'Report'
      REST::Admin::ReportSerializer
    when 'Status'
      REST::StatusSerializer
    when 'Follow'
      REST::FollowSerializer
    when 'Mute'
      REST::MuteSerializer
    when 'Block'
      REST::BlockSerializer
    else
      super
    end
  end

  attributes :event, :created_at

  has_one :virtual_object, key: :object

  def virtual_object
    object.object
  end

  def event
    object.type
  end
end
