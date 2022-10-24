# frozen_string_literal: true

class GroupMembersController < ApplicationController
  MEMBERS_PER_PAGE = 12

  include WebAppControllerConcern
  include GroupOwnedConcern
  include SignatureAuthentication
  include Authorization

  before_action :require_account_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_instance_presenter
  before_action :set_cache_headers

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, unless: :whitelist_mode?

  def index
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?
      end

      format.json do
        raise Mastodon::NotPermittedError if page_requested? && @group.hide_members?

        expires_in(page_requested? ? 0 : 3.minutes, public: public_fetch_mode?)

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json',
               fields: restrict_fields_to
      end
    end
  end

  private

  def group_id_param
    params[:group_id]
  end

  def memberships
    return @memberships if defined?(@memberships)

    scope = @group.memberships.reorder(id: :desc)
    scope = scope.where.not(account_id: current_account.excluded_from_timeline_account_ids) if user_signed_in?
    @memberships = scope.recent.page(params[:page]).per(MEMBERS_PER_PAGE).preload(:account)
  end

  def page_requested?
    params[:page].present?
  end

  def page_url(page)
    group_members_url(@group, page: page) unless page.nil?
  end

  def next_page_url
    page_url(memberships.next_page) if memberships.respond_to?(:next_page)
  end

  def prev_page_url
    page_url(memberships.prev_page) if memberships.respond_to?(:prev_page)
  end

  def collection_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: group_members_url(@group, page: params.fetch(:page, 1)),
        type: :ordered,
        size: @group.members_count,
        items: memberships.map { |m| ActivityPub::TagManager.instance.uri_for(m.account) },
        part_of: group_members_url(@group),
        next: next_page_url,
        prev: prev_page_url
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: group_members_url(@group),
        type: :ordered,
        size: @group.members_count,
        first: page_url(1)
      )
    end
  end

  def restrict_fields_to
    if page_requested? || !@group.hide_members?
      # Return all fields
    else
      %i(id type total_items)
    end
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
