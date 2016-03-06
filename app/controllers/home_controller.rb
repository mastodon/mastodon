class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @statuses = Status.where(account: ([current_user.account] + current_user.account.following)).where('reblog_of_id IS NULL OR account_id != ?', current_user.account.id).order('created_at desc')
  end
end
