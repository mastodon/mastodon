class StreamEntriesController < ApplicationController
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
    @account = Account.find_by!(username: params[:account_username], domain: nil)
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.find(params[:id])
  end
end
