# frozen_string_literal: true

class HomeController < ApplicationController
  include WebAppControllerConcern

  before_action :redirect_unauthenticated_to_permalinks!
  before_action :set_instance_presenter

  def index; end

  private

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in?

    redirect_path = PermalinkRedirector.new(request.path).redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
