# frozen_string_literal: true

class Admin::Trends::TagsController < Admin::BaseController
  def index
    authorize :tag, :index?

    @tags = filtered_tags.page(params[:page])
    @form = Form::TagBatch.new
  end

  def batch
    @form = Form::TagBatch.new(form_tag_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.accounts.no_account_selected')
  ensure
    redirect_to admin_trends_tags_path(filter_params)
  end

  private

  def filtered_tags
    TagFilter.new(filter_params).results
  end

  def filter_params
    params.slice(:page, *TagFilter::KEYS).permit(:page, *TagFilter::KEYS)
  end

  def form_tag_batch_params
    params.require(:form_tag_batch).permit(:action, tag_ids: [])
  end

  def action_from_button
    if params[:approve]
      'approve'
    elsif params[:reject]
      'reject'
    end
  end
end
