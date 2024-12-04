# frozen_string_literal: true

class ListsController < ApplicationController
  include WebAppControllerConcern

  before_action :set_list

  def show; end

  private

  def set_list
    @list = List.where(type: :public_list).find(params[:id])
  end
end
