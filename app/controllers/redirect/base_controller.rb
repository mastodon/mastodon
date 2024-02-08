# frozen_string_literal: true

class Redirect::BaseController < ApplicationController
  vary_by 'Accept-Language'

  before_action :set_resource
  before_action :set_app_body_class

  def show
    @redirect_path = ActivityPub::TagManager.instance.url_for(@resource)

    render 'redirects/show', layout: 'application'
  end

  private

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def set_resource
    raise NotImplementedError
  end
end
