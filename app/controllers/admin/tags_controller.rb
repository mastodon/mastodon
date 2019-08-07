# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tags, only: :index
    before_action :set_tag, except: :index

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
  end
end
