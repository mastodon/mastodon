# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tag, except: [:index]

    PER_PAGE = 20
    PERIOD_DAYS = 6.days

    def index
      authorize :tag, :index?

      @tags = filtered_tags.page(params[:page]).per(PER_PAGE)
    end

    def show
      authorize @tag, :show?

      @time_period = report_range
      @action_logs = Admin::ActionLogFilter.new(target_tag: @tag.formatted_name).results.limit(5)
    end

    def update
      authorize @tag, :update?

      if @tag.update(tag_params.merge(reviewed_at: Time.now.utc))
        log_action_from_param(tag_params)
        redirect_to admin_tag_path(@tag.id), notice: I18n.t('admin.tags.updated_msg')
      else
        @time_period = report_range

        render :show
      end
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def report_range
      (PERIOD_DAYS.ago.to_date...Time.now.utc.to_date)
    end

    def tag_params
      params
        .expect(tag: [:name, :display_name, :trendable, :usable, :listable])
    end

    def filtered_tags
      TagFilter.new(filter_params.with_defaults(order: 'newest')).results
    end

    def filter_params
      params.slice(:page, *TagFilter::KEYS).permit(:page, *TagFilter::KEYS)
    end

    def log_action_from_param(params)
      if params[:listable] == 'true'
        log_action :listable, @tag
      elsif params[:listable] == 'false'
        log_action :not_listable, @tag
      end
      if params[:trendable] == 'true'
        log_action :trendable, @tag
      elsif params[:trendable] == 'false'
        log_action :not_trendable, @tag
      end
      if params[:usable] == 'true'
        log_action :usable, @tag
      elsif params[:usable] == 'false'
        log_action :not_usable, @tag
      end
    end
  end
end
