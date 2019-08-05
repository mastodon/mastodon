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
        redirect_to admin_tag_path(@tag.id)
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
      scope = scope.reviewed if filter_params[:review] == 'reviewed'
      scope = scope.pending_review if filter_params[:review] == 'pending_review'
      scope.reorder(score: :desc)
    end

    def filter_params
      params.slice(:context, :review).permit(:context, :review)
    end

    def tag_params
      params.require(:tag).permit(:name, :trendable, :usable, :listable)
    end
  end
end
