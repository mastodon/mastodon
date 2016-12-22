# frozen_string_literal: true

class StreamEntriesController < ApplicationController
  layout 'public'

  before_action :set_account
  before_action :set_stream_entry
  before_action :set_link_headers
  before_action :check_account_suspension

  def show
    respond_to do |format|
      format.html do
        return gone if @stream_entry.activity.nil?

        if @stream_entry.activity_type == 'Status'
          @ancestors   = @stream_entry.activity.ancestors(current_account)
          @descendants = @stream_entry.activity.descendants(current_account)
        end
      end

      format.atom
    end
  end

  def embed
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    @external_links = true

    return gone if @stream_entry.activity.nil?

    render layout: 'embedded'
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
    @type         = @stream_entry.activity_type.downcase

    raise ActiveRecord::RecordNotFound if @stream_entry.hidden? && (@stream_entry.activity_type != 'Status' || (@stream_entry.activity_type == 'Status' && !@stream_entry.activity.permitted?(current_account)))
  end

  def check_account_suspension
    head 410 if @account.suspended?
  end
end
