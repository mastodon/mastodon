# frozen_string_literal: true

class Redirect::StatusesController < Redirect::BaseController
  private

  def set_resource
    @resource = Status.find(params[:id])
    not_found if @resource.local? || !@resource.distributable?
  end
end
