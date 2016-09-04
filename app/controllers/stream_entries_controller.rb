class StreamEntriesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_stream_entry

  def show
    @type = @stream_entry.activity_type.downcase

    respond_to do |format|
      format.html
      format.atom
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.find(params[:id])
  end
end
