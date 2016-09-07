class AccountsController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_webfinger_header

  def show
    respond_to do |format|
      format.html { @statuses = @account.statuses.order('id desc').with_includes.with_counters.paginate(page: params[:page], per_page: 10)}

      format.atom do
        @entries = @account.stream_entries.order('id desc').with_includes.paginate_by_max_id(20, params[:max_id] || nil)

        ActiveRecord::Associations::Preloader.new.preload(@entries.select { |a| a.activity_type == 'Status' }, activity: [:mentions, :media_attachments, reblog: :account, thread: :account])
        ActiveRecord::Associations::Preloader.new.preload(@entries.select { |a| a.activity_type == 'Favourite' }, activity: [:account, :status])
        ActiveRecord::Associations::Preloader.new.preload(@entries.select { |a| a.activity_type == 'Follow' }, activity: :target_account)
      end
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
    @account = Account.find_local!(params[:username])
  end

  def set_webfinger_header
    response.headers['Link'] = "<#{webfinger_account_url}>; rel=\"lrdd\"; type=\"application/xrd+xml\""
  end

  def webfinger_account_url
    webfinger_url(resource: "acct:#{@account.acct}@#{Rails.configuration.x.local_domain}")
  end
end
