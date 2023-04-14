# frozen_string_literal: true

class Api::V1::Admin::Trends::Links::PreviewCardProvidersController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }, only: :index
  before_action -> { authorize_if_got_token! :'admin:write' }, except: :index
  before_action :set_providers, only: :index

  after_action :verify_authorized

  def index
    authorize :preview_card_provider, :index?

    render json: @providers, each_serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  def approve
    authorize :preview_card_provider, :review?

    provider = PreviewCardProvider.find(params[:id])
    provider.update(trendable: true, reviewed_at: Time.now.utc)
    render json: provider, serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  def reject
    authorize :preview_card_provider, :review?

    provider = PreviewCardProvider.find(params[:id])
    provider.update(trendable: false, reviewed_at: Time.now.utc)
    render json: provider, serializer: REST::Admin::Trends::Links::PreviewCardProviderSerializer
  end

  private

  def enabled?
    current_user&.can?(:manage_taxonomies)
  end

  def set_providers
    @providers = PreviewCardProvider.all
  end
end
