# frozen_string_literal: true

class Settings::FeaturedTagsController < Settings::BaseController
  before_action :set_featured_tags, only: :index
  before_action :set_featured_tag, except: [:index, :create]
  before_action :set_recently_used_tags, only: :index

  RECENT_TAGS_LIMIT = 10

  def index
    @featured_tag = FeaturedTag.new
  end

  def create
    @featured_tag = CreateFeaturedTagService.new.call(current_account, featured_tag_params[:name], force: false)

    if @featured_tag.valid?
      redirect_to settings_featured_tags_path
    else
      set_featured_tags
      set_recently_used_tags

      render :index
    end
  end

  def destroy
    RemoveFeaturedTagService.new.call(current_account, @featured_tag)
    redirect_to settings_featured_tags_path
  end

  private

  def set_featured_tag
    @featured_tag = current_account.featured_tags.find(params[:id])
  end

  def set_featured_tags
    @featured_tags = current_account.featured_tags.order(statuses_count: :desc).reject(&:new_record?)
  end

  def set_recently_used_tags
    @recently_used_tags = Tag.suggestions_for_account(current_account).limit(RECENT_TAGS_LIMIT)
  end

  def featured_tag_params
    params.require(:featured_tag).permit(:name)
  end
end
