class AccountsController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_webfinger_header

  def show
    respond_to do |format|
      format.html { @statuses = @account.statuses.order('id desc').with_includes.with_counters.paginate(page: params[:page], per_page: 10)}
      format.atom
    end
  end

  def followers
    @followers = @account.followers.order('follows.created_at desc').paginate(page: params[:page], per_page: 6)
  end

  def following
    @following = @account.following.order('follows.created_at desc').paginate(page: params[:page], per_page: 6)
  end

  private

  def set_account
    @account = Account.find_by!(username: params[:username], domain: nil)
  end

  def set_webfinger_header
    response.headers['Link'] = "<#{webfinger_account_url}>; rel=\"lrdd\"; type=\"application/xrd+xml\""
  end

  def webfinger_account_url
    webfinger_url(resource: "acct:#{@account.acct}@#{Rails.configuration.x.local_domain}")
  end
end
