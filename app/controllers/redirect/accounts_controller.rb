# frozen_string_literal: true

class Redirect::AccountsController < ApplicationController
  private

  def set_resource
    @resource = Account.find(params[:id])
    not_found if @resource.local?
  end
end
