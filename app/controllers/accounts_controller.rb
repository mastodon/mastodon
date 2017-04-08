# frozen_string_literal: true

class AccountsController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_link_headers
  before_action :authenticate_user!, only: [:follow, :unfollow]
  before_action :check_account_suspension

  def show
    respond_to do |format|
      format.html do
        @statuses = @account.statuses.permitted_for(@account, current_account).order('id desc').paginate_by_max_id(20, params[:max_id], params[:since_id])
        @statuses = cache_collection(@statuses, Status)
      end

      format.atom do
        @entries = @account.stream_entries.order('id desc').where(hidden: false).with_includes.paginate_by_max_id(20, params[:max_id], params[:since_id])
        render xml: AtomSerializer.render(AtomSerializer.new.feed(@account, @entries.to_a))
      end

      format.activitystreams2
    end
  end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    redirect_to account_path(@account)
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    redirect_to account_path(@account)
  end

  def followers
    @followers = @account.followers.order('follows.created_at desc').paginate(page: params[:page], per_page: 12)
  end

  def following
    @following = @account.following.order('follows.created_at desc').paginate(page: params[:page], per_page: 12)
  end

  private

  def set_account
    @account = Account.find_local!(params[:username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[webfinger_account_url, [%w(rel lrdd), %w(type application/xrd+xml)]], [account_url(@account, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]]])
  end

  def webfinger_account_url
    webfinger_url(resource: "acct:#{@account.acct}@#{Rails.configuration.x.local_domain}")
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
