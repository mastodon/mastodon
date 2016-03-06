class StreamEntriesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_stream_entry
  before_action :authenticate_user!, only: [:reblog, :favourite]
  before_action :only_statuses!, only: [:reblog, :favourite]

  def show
    @type = @stream_entry.activity_type.downcase

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def reblog
    ReblogService.new.(current_user.account, @stream_entry.activity)
    redirect_to root_path
  end

  def favourite
    FavouriteService.new.(current_user.account, @stream_entry.activity)
    redirect_to root_path
  end

  private

  def set_account
    @account = Account.find_by!(username: params[:account_username], domain: nil)
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.find(params[:id])
  end

  def only_statuses!
    redirect_to root_url unless @stream_entry.activity_type == 'Status'
  end
end
