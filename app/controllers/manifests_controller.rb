# frozen_string_literal: true

class ManifestsController < ApplicationController
  before_action :set_instance_presenter

  def show; end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
