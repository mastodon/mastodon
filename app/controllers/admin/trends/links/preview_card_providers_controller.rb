# frozen_string_literal: true

class Admin::Trends::Links::PreviewCardProvidersController < Admin::BaseController
  def index
    authorize :preview_card_provider, :review?

    @pending_preview_card_providers_count = PreviewCardProvider.unreviewed.async_count
    @preview_card_providers = filtered_preview_card_providers.page(params[:page])
    @form = Trends::PreviewCardProviderBatch.new
  end

  def batch
    authorize :preview_card_provider, :review?

    @form = Trends::PreviewCardProviderBatch.new(trends_preview_card_provider_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.trends.links.publishers.no_publisher_selected')
  ensure
    redirect_to admin_trends_links_preview_card_providers_path(filter_params)
  end

  private

  def filtered_preview_card_providers
    Trends::PreviewCardProviderFilter.new(filter_params).results
  end

  def filter_params
    params.slice(:page, *Trends::PreviewCardProviderFilter::KEYS).permit(:page, *Trends::PreviewCardProviderFilter::KEYS)
  end

  def trends_preview_card_provider_batch_params
    params
      .expect(trends_preview_card_provider_batch: [:action, preview_card_provider_ids: []])
  end

  def action_from_button
    if params[:approve]
      'approve'
    elsif params[:reject]
      'reject'
    end
  end
end
