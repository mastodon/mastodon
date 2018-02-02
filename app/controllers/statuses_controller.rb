# frozen_string_literal: true

class StatusesController < ApplicationController
  include SignatureAuthentication
  include Authorization

  layout 'public'

  before_action :set_account
  before_action :set_status
  before_action :set_link_headers
  before_action :check_account_suspension
  before_action :redirect_to_original, only: [:show]
  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.html do
        @ancestors   = @status.reply? ? cache_collection(@status.ancestors(current_account), Status) : []
        @descendants = cache_collection(@status.descendants(current_account), Status)

        render 'stream_entries/show'
      end

      format.json do
        skip_session! unless @stream_entry.hidden?

        render_cached_json(['activitypub', 'note', @status.cache_key], content_type: 'application/activity+json', public: !@stream_entry.hidden?) do
          ActiveModelSerializers::SerializableResource.new(@status, serializer: ActivityPub::NoteSerializer, adapter: ActivityPub::Adapter)
        end
      end
    end
  end

  def activity
    skip_session!

    render_cached_json(['activitypub', 'activity', @status.cache_key], content_type: 'application/activity+json', public: !@stream_entry.hidden?) do
      ActiveModelSerializers::SerializableResource.new(@status, serializer: ActivityPub::ActivitySerializer, adapter: ActivityPub::Adapter)
    end
  end

  def embed
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    render 'stream_entries/embed', layout: 'embedded'
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new(
      [
        [account_stream_entry_url(@account, @status.stream_entry, format: 'atom'), [%w(rel alternate), %w(type application/atom+xml)]],
        [ActivityPub::TagManager.instance.uri_for(@status), [%w(rel alternate), %w(type application/activity+json)]],
      ]
    )
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

  def redirect_to_original
    redirect_to ::TagManager.instance.url_for(@status.reblog) if @status.reblog?
  end
end
