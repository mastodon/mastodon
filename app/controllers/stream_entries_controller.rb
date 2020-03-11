# frozen_string_literal: true

class StreamEntriesController < ApplicationController
  include Authorization
  include SignatureVerification

  layout 'public'

  before_action :set_account
  before_action :set_stream_entry
  before_action :set_link_headers
  before_action :check_account_suspension
  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.html do
        expires_in 5.minutes, public: true unless @stream_entry.hidden?

        redirect_to short_account_status_url(params[:account_username], @stream_entry.activity)
      end

      format.atom do
        expires_in 3.minutes, public: true unless @stream_entry.hidden?

        render xml: OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.entry(@stream_entry, true))
      end
    end
  end

  def embed
    redirect_to embed_short_account_status_url(@account, @stream_entry.activity), status: 301
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new(
      [
        [account_stream_entry_url(@account, @stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]],
        [ActivityPub::TagManager.instance.uri_for(@stream_entry.activity), [%w(rel alternate), %w(type application/activity+json)]],
      ]
    )
  end

  def set_stream_entry
    @stream_entry = @account.stream_entries.where(activity_type: 'Status').find(params[:id])
    @type         = 'status'

    raise ActiveRecord::RecordNotFound if @stream_entry.activity.nil?
    authorize @stream_entry.activity, :show? if @stream_entry.hidden?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404
    raise ActiveRecord::RecordNotFound
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
