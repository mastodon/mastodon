# frozen_string_literal: true

class REST::Admin::WebhookEventSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Account'
      REST::Admin::AccountSerializer
    when 'Report'
      REST::Admin::ReportSerializer
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
