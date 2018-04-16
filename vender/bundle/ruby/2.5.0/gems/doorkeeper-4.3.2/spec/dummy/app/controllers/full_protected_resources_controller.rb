class FullProtectedResourcesController < ApplicationController
  before_action -> { doorkeeper_authorize! :write, :admin }, only: :show
  before_action :doorkeeper_authorize!, only: :index

  def index
    render plain: 'index'
  end

  def show
    render plain: 'show'
  end
end
