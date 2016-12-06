# frozen_string_literal: true

class StreamEntriesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_stream_entry
  before_action :set_link_headers
  before_action :check_account_suspension

  def show
    @type = @stream_entry.activity_type.downcase

    respond_to do |format|
      format.html do
        return gone if @stream_entry.activity.nil?

        if @stream_entry.activity_type == 'Status'
          @ancestors   = @stream_entry.activity.ancestors
          @descendants = @stream_entry.activity.descendants
        end
      end

      format.atom
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[account_stream_entry_url(@account, @stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]]])
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.find(params[:id])
  end

  def check_account_suspension
    head 410 if @account.suspended?
  end
end
