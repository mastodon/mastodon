# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tags, only: :index
    before_action :set_tag, except: :index
    before_action :set_usage_by_domain, except: :index
    before_action :set_counters, except: :index

    def index
      authorize :tag, :index?
    end

    def show
      authorize @tag, :show?
    end

    def update
      authorize @tag, :update?

      if @tag.update(tag_params.merge(reviewed_at: Time.now.utc))
        redirect_to admin_tag_path(@tag.id), notice: I18n.t('admin.tags.updated_msg')
      else
        render :show
      end
    end

    private

    def set_tags
      @tags = filtered_tags.page(params[:page])
    end

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_usage_by_domain
      @usage_by_domain = @tag.statuses
                             .where(visibility: :public)
                             .where(Status.arel_table[:id].gteq(Mastodon::Snowflake.id_at(Time.now.utc.beginning_of_day)))
                             .joins(:account)
                             .group('accounts.domain')
                             .reorder('statuses_count desc')
                             .pluck('accounts.domain, count(*) AS statuses_count')
    end

    def set_counters
      @accounts_today = @tag.history.first[:accounts]
      @accounts_week  = Redis.current.pfcount(*current_week_days.map { |day| "activity:tags:#{@tag.id}:#{day}:accounts" })
    end

    def filtered_tags
      scope = Tag
      scope = scope.discoverable if filter_params[:context] == 'directory'
      scope = scope.unreviewed if filter_params[:review] == 'unreviewed'
      scope = scope.reviewed.order(reviewed_at: :desc) if filter_params[:review] == 'reviewed'
      scope = scope.pending_review.order(requested_review_at: :desc) if filter_params[:review] == 'pending_review'
      scope.order(score: :desc)
    end

    def filter_params
      params.slice(:context, :review).permit(:context, :review)
    end

    def tag_params
      params.require(:tag).permit(:name, :trendable, :usable, :listable)
    end

    def current_week_days
      now = Time.now.utc.beginning_of_day.to_date

      (Date.commercial(now.cwyear, now.cweek)..now).map do |date|
        date.to_time(:utc).beginning_of_day.to_i
      end
    end
  end
end
