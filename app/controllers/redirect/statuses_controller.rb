# frozen_string_literal: true

class Redirect::StatusesController < ApplicationController
  vary_by 'Accept-Language'

  before_action :set_status
  before_action :set_app_body_class

  def show
    @redirect_path = ActivityPub::TagManager.instance.url_for(@status)

    render 'redirects/show', layout: 'application'
  end

  private

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def set_status
    @status = Status.find(params[:id])
    not_found if @status.local? || !@status.distributable?
  end
end
