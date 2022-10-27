# frozen_string_literal: true

class Webhooks::EventPresenter < ActiveModelSerializers::Model
  attributes :type, :created_at, :object

  def initialize(type, object)
    super()

    @type       = type
    @created_at = Time.now.utc
    @object     = object
  end
end
