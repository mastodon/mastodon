# frozen_string_literal: true

class StatusesController < ApplicationController
  include SignatureAuthentication
  include Authorization

  ANCESTORS_LIMIT         = 40
  DESCENDANTS_LIMIT       = 60
  DESCENDANTS_DEPTH_LIMIT = 20

  layout 'public'

  before_action :set_account
  before_action :set_status
  before_action :set_link_headers
  before_action :check_account_suspension
  before_action :redirect_to_original, only: [:show]
  before_action :set_referrer_policy_header, only: [:show]
  before_action :set_cache_headers

  def show
    respond_to do |format|
      format.html do
        set_ancestors
        set_descendants

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

  def create_descendant_thread(depth, statuses)
    if depth < DESCENDANTS_DEPTH_LIMIT
      { statuses: statuses }
    else
      next_status = statuses.pop
      { statuses: statuses, next_status: next_status }
    end
  end

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_ancestors
    @ancestors     = @status.reply? ? cache_collection(@status.ancestors(ANCESTORS_LIMIT, current_account), Status) : []
    @next_ancestor = @ancestors.size < ANCESTORS_LIMIT ? nil : @ancestors.shift
  end

  def set_descendants
    @max_descendant_thread_id   = params[:max_descendant_thread_id]&.to_i
    @since_descendant_thread_id = params[:since_descendant_thread_id]&.to_i

    descendants = cache_collection(
      @status.descendants(
        DESCENDANTS_LIMIT,
        current_account,
        @max_descendant_thread_id,
        @since_descendant_thread_id,
        DESCENDANTS_DEPTH_LIMIT
      ),
      Status
    )

    @descendant_threads = []

    if descendants.present?
      statuses = [descendants.first]
      depth    = 1

      descendants.drop(1).each_with_index do |descendant, index|
        if descendants[index].id == descendant.in_reply_to_id
          depth += 1
          statuses << descendant
        else
          @descendant_threads << create_descendant_thread(depth, statuses)

          @descendant_threads.reverse_each do |descendant_thread|
            statuses = descendant_thread[:statuses]

            index = statuses.find_index do |thread_status|
              thread_status.id == descendant.in_reply_to_id
            end

            if index.present?
              depth += index - statuses.size
              break
            end

            depth -= statuses.size
          end

          statuses = [descendant]
        end
      end

      @descendant_threads << create_descendant_thread(depth, statuses)
    end

    @max_descendant_thread_id = @descendant_threads.pop[:statuses].first.id if descendants.size >= DESCENDANTS_LIMIT
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

  def set_referrer_policy_header
    return if @status.public_visibility? || @status.unlisted_visibility?
    response.headers['Referrer-Policy'] = 'origin'
  end
end
