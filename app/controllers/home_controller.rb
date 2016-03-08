class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    feed      = Feed.new(:home, current_user.account)
    @statuses = feed.get(20, (params[:offset] || 0).to_i)
  end
end
