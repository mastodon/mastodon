# frozen_string_literal: true

class StatusesController < ApplicationController
  include Authorization

  layout 'public'

  before_action :set_account
  before_action :set_status
  before_action :set_link_headers
  before_action :check_account_suspension

  def show
    @ancestors   = @status.reply? ? cache_collection(@status.ancestors(current_account), Status) : []
    @descendants = cache_collection(@status.descendants(current_account), Status)

    render 'stream_entries/show'
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[account_stream_entry_url(@account, @status.stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]]])
  end

  def set_status
    @status       = @account.statuses.find(params[:id])
    @stream_entry = @status.stream_entry
    @type         = @stream_entry.activity_type.downcase

    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404
    raise ActiveRecord::RecordNotFound
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
