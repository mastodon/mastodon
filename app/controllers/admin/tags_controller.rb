# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tags, only: :index
    before_action :set_tag, except: [:index, :batch, :approve_all, :reject_all]
    before_action :set_usage_by_domain, except: [:index, :batch, :approve_all, :reject_all]
    before_action :set_counters, except: [:index, :batch, :approve_all, :reject_all]

    def index
      authorize :tag, :index?

      @form = Form::TagBatch.new
    end

    def batch
      @form = Form::TagBatch.new(form_tag_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.accounts.no_account_selected')
    ensure
      redirect_to admin_tags_path(filter_params)
    end

    def approve_all
      Form::TagBatch.new(current_account: current_account, tag_ids: Tag.pending_review.pluck(:id), action: 'approve').save
      redirect_to admin_tags_path(filter_params)
    end

    def reject_all
      Form::TagBatch.new(current_account: current_account, tag_ids: Tag.pending_review.pluck(:id), action: 'reject').save
      redirect_to admin_tags_path(filter_params)
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
                             .with_public_visibility
                             .excluding_silenced_accounts
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
      scope.order(max_score: :desc)
    end

    def filter_params
      params.slice(:context, :review, :page).permit(:context, :review, :page)
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
end
