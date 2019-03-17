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
  before_action :set_instance_presenter
  before_action :set_link_headers
  before_action :check_account_suspension
  before_action :redirect_to_original, only: [:show]
  before_action :set_referrer_policy_header, only: [:show]
  before_action :set_cache_headers
  before_action :set_replies, only: [:replies]

  content_security_policy only: :embed do |p|
    p.frame_ancestors(false)
  end

  def show
    respond_to do |format|
      format.html do
        mark_cacheable! unless user_signed_in?

        @body_classes = 'with-modals'

        set_ancestors
        set_descendants

        render 'stream_entries/show'
      end

      format.json do
        mark_cacheable! unless @stream_entry.hidden?

        render_cached_json(['activitypub', 'note', @status], content_type: 'application/activity+json', public: !@stream_entry.hidden?) do
          ActiveModelSerializers::SerializableResource.new(@status, serializer: ActivityPub::NoteSerializer, adapter: ActivityPub::Adapter)
        end
      end
    end
  end

  def activity
    skip_session!

    render_cached_json(['activitypub', 'activity', @status], content_type: 'application/activity+json', public: !@stream_entry.hidden?) do
      ActiveModelSerializers::SerializableResource.new(@status, serializer: ActivityPub::ActivitySerializer, adapter: ActivityPub::Adapter)
    end
  end

  def embed
    raise ActiveRecord::RecordNotFound if @status.hidden?

    skip_session!
    expires_in 180, public: true
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    @autoplay = ActiveModel::Type::Boolean.new.cast(params[:autoplay])

    render 'stream_entries/embed', layout: 'embedded'
  end

  def replies
    skip_session!

    render json: replies_collection_presenter,
           serializer: ActivityPub::CollectionSerializer,
           adapter: ActivityPub::Adapter,
           content_type: 'application/activity+json',
           skip_activities: true
  end

  private

  def replies_collection_presenter
    page = ActivityPub::CollectionPresenter.new(
      id: replies_account_status_url(@account, @status, page_params),
      type: :unordered,
      part_of: replies_account_status_url(@account, @status),
      next: next_page,
      items: @replies.map { |status| status.local ? status : status.id }
    )
    if page_requested?
      page
    else
      ActivityPub::CollectionPresenter.new(
        id: replies_account_status_url(@account, @status),
        type: :unordered,
        first: page
      )
    end
  end

  def create_descendant_thread(starting_depth, statuses)
    depth = starting_depth + statuses.size
    if depth < DESCENDANTS_DEPTH_LIMIT
      { statuses: statuses, starting_depth: starting_depth }
    else
      next_status = statuses.pop
      { statuses: statuses, starting_depth: starting_depth, next_status: next_status }
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
      statuses       = [descendants.first]
      starting_depth = 0

      descendants.drop(1).each_with_index do |descendant, index|
        if descendants[index].id == descendant.in_reply_to_id
          statuses << descendant
        else
          @descendant_threads << create_descendant_thread(starting_depth, statuses)

          # The thread is broken, assume it's a reply to the root status
          starting_depth = 0

          # ... unless we can find its ancestor in one of the already-processed threads
          @descendant_threads.reverse_each do |descendant_thread|
            statuses = descendant_thread[:statuses]

            index = statuses.find_index do |thread_status|
              thread_status.id == descendant.in_reply_to_id
            end

            if index.present?
              starting_depth = descendant_thread[:starting_depth] + index + 1
              break
            end
          end

          statuses = [descendant]
        end
      end

      @descendant_threads << create_descendant_thread(starting_depth, statuses)
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

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
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

  def page_requested?
    params[:page] == 'true'
  end

  def set_replies
    @replies = page_params[:other_accounts] ? Status.where.not(account_id: @account.id) : @account.statuses
    @replies = @replies.where(in_reply_to_id: @status.id, visibility: [:public, :unlisted])
    @replies = @replies.paginate_by_min_id(DESCENDANTS_LIMIT, params[:min_id])
  end

  def next_page
    last_reply = @replies.last
    return if last_reply.nil?
    same_account = last_reply.account_id == @account.id
    return unless same_account || @replies.size == DESCENDANTS_LIMIT
    same_account = false unless @replies.size == DESCENDANTS_LIMIT
    replies_account_status_url(@account, @status, page: true, min_id: last_reply.id, other_accounts: !same_account)
  end

  def page_params
    { page: true, other_accounts: params[:other_accounts], min_id: params[:min_id] }.compact
  end
end
