class HomeController < ApplicationController
  layout 'dashboard'

  before_action :authenticate_user!

  def index
    feed      = Feed.new(:home, current_user.account)
    @statuses = feed.get(20, (params[:offset] || 0).to_i)
  end

  def mentions
    feed      = Feed.new(:mentions, current_user.account)
    @statuses = feed.get(20, (params[:offset] || 0).to_i)
    render action: :index
  end
end
