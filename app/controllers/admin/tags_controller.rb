# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tag

    def show
      authorize @tag, :show?

      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
    end

    def update
      authorize @tag, :update?

      if @tag.update(tag_params.merge(reviewed_at: Time.now.utc))
        redirect_to admin_tag_path(@tag.id), notice: I18n.t('admin.tags.updated_msg')
      else
        @time_period = (6.days.ago.to_date...Time.now.utc.to_date)

        render :show
      end
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :display_name, :trendable, :usable, :listable)
    end
  end
end
