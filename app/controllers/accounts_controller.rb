class AccountsController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_webfinger_header
  before_action :authenticate_user!, only: [:follow, :unfollow]

  def show
    @statuses = @account.statuses.order('id desc').includes(thread: [:account], reblog: [:account], stream_entry: [])

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def follow
    current_user.account.follow!(@account)
    redirect_to root_path
  end

  def unfollow
    current_user.account.unfollow!(@account)
    redirect_to root_path
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
