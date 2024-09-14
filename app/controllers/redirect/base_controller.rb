# frozen_string_literal: true

class Redirect::BaseController < ApplicationController
  vary_by 'Accept-Language'

  before_action :set_resource

  def show
    @redirect_path = ActivityPub::TagManager.instance.url_for(@resource)

    render 'redirects/show', layout: 'application'
  end

  private

  def set_resource
    raise NotImplementedError
  end
end
