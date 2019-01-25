# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tags, only: :index
    before_action :set_tag, except: :index
    before_action :set_filter_params

    def index
      authorize :tag, :index?
    end

    def hide
      authorize @tag, :hide?
      @tag.account_tag_stat.update!(hidden: true)
      redirect_to admin_tags_path(@filter_params)
    end

    def unhide
      authorize @tag, :unhide?
      @tag.account_tag_stat.update!(hidden: false)
      redirect_to admin_tags_path(@filter_params)
    end

    private

    def set_tags
      @tags = Tag.discoverable
      @tags.merge!(Tag.hidden) if filter_params[:hidden]
    end

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_filter_params
      @filter_params = filter_params.to_hash.symbolize_keys
    end

    def filter_params
      params.permit(:hidden)
    end
  end
end
