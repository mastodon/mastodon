class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @body_classes = 'app-body'
    @home         = Feed.new(:home, current_user.account).get(20)
    @mentions     = Feed.new(:mentions, current_user.account).get(20)
  end
end
