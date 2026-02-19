# frozen_string_literal: true

class Admin::Trends::TagsController < Admin::BaseController
  def index
    authorize :tag, :review?

    @pending_tags_count = pending_tags.async_count
    @tags = filtered_tags.page(params[:page])
    @form = Trends::TagBatch.new
  end

  def batch
    authorize :tag, :review?

    @form = Trends::TagBatch.new(trends_tag_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.trends.tags.no_tag_selected')
  ensure
    redirect_to admin_trends_tags_path(filter_params)
  end

  private

  def pending_tags
    Trends::TagFilter.new(status: :pending_review).results
  end

  def filtered_tags
    Trends::TagFilter.new(filter_params).results
  end

  def filter_params
    params.slice(:page, *Trends::TagFilter::KEYS).permit(:page, *Trends::TagFilter::KEYS)
  end

  def trends_tag_batch_params
    params
      .expect(trends_tag_batch: [:action, tag_ids: []])
  end

  def action_from_button
    if params[:approve]
      'approve'
    elsif params[:reject]
      'reject'
    end
  end
end
