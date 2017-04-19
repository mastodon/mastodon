# frozen_string_literal: true

class Api::V1::InstancesController < ApiController
  before_action :set_instance_presenter, only: [:show]
  respond_to :json

  def show; end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end