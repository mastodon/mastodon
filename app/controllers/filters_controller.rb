# frozen_string_literal: true

class FiltersController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_filter, only: [:edit, :update, :destroy]

  def index
    @filters = current_account.custom_filters.includes(:keywords, :statuses).order(:phrase)
  end

  def new
    @filter = current_account.custom_filters.build(action: :warn)
    @filter.keywords.build
  end

  def edit; end

  def create
    @filter = current_account.custom_filters.build(resource_params)

    if @filter.save
      redirect_to filters_path
    else
      render :new
    end
  end

  def update
    if @filter.update(resource_params)
      redirect_to filters_path
    else
      render :edit
    end
  end

  def destroy
    @filter.destroy
    redirect_to filters_path
  end

  private

  def set_filter
    @filter = current_account.custom_filters.find(params[:id])
  end

  def resource_params
    params.expect(custom_filter: [:title, :expires_in, :filter_action, context: [], keywords_attributes: [[:id, :keyword, :whole_word, :_destroy]]])
  end
end
