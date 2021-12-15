# frozen_string_literal: true

class Admin::Trends::LinksController < Admin::BaseController
  def index
    authorize :preview_card, :index?

    @preview_cards = filtered_preview_cards.page(params[:page])
    @form          = Form::PreviewCardBatch.new
  end

  def batch
    @form = Form::PreviewCardBatch.new(form_preview_card_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.accounts.no_account_selected')
  ensure
    redirect_to admin_trends_links_path(filter_params)
  end

  private

  def filtered_preview_cards
    PreviewCardFilter.new(filter_params.with_defaults(trending: 'all')).results
  end

  def filter_params
    params.slice(:page, *PreviewCardFilter::KEYS).permit(:page, *PreviewCardFilter::KEYS)
  end

  def form_preview_card_batch_params
    params.require(:form_preview_card_batch).permit(:action, preview_card_ids: [])
  end

  def action_from_button
    if params[:approve]
      'approve'
    elsif params[:approve_all]
      'approve_all'
    elsif params[:reject]
      'reject'
    elsif params[:reject_all]
      'reject_all'
    end
  end
end
