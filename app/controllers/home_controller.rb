class HomeController < ApplicationController
  layout 'dashboard'

  before_action :authenticate_user!

  def index
    @timeline = Feed.new(:home, current_user.account).get(10, params[:max_id])
  end
end
