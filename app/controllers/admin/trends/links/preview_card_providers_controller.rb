# frozen_string_literal: true

class Admin::Trends::Links::PreviewCardProvidersController < Admin::BaseController
  def index
    authorize :preview_card_provider, :index?

    @preview_card_providers = filtered_preview_card_providers.page(params[:page])
    @form = Form::PreviewCardProviderBatch.new
  end

  def batch
    @form = Form::PreviewCardProviderBatch.new(form_preview_card_provider_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.accounts.no_account_selected')
  ensure
    redirect_to admin_trends_links_preview_card_providers_path(filter_params)
  end

  private

  def filtered_preview_card_providers
    PreviewCardProviderFilter.new(filter_params).results
  end

  def filter_params
    params.slice(:page, *PreviewCardProviderFilter::KEYS).permit(:page, *PreviewCardProviderFilter::KEYS)
  end

  def form_preview_card_provider_batch_params
    params.require(:form_preview_card_provider_batch).permit(:action, preview_card_provider_ids: [])
  end

  def action_from_button
    if params[:approve]
      'approve'
    elsif params[:reject]
      'reject'
    end
  end
end
