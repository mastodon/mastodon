# frozen_string_literal: true

class Settings::FeaturedTagsController < Settings::BaseController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_featured_tags, only: :index
  before_action :set_featured_tag, except: [:index, :create]

  def index
    @featured_tag   = FeaturedTag.new
    @most_used_tags = Tag.most_used(current_account).where.not(id: @featured_tags.map(&:id)).limit(10)
  end

  def create
    @featured_tag = current_account.featured_tags.new(featured_tag_params)
    @featured_tag.reset_data
    @featured_tag.save

    redirect_to settings_featured_tags_path
  end

  def destroy
    @featured_tag.destroy
    redirect_to settings_featured_tags_path
  end

  private

  def set_featured_tag
    @featured_tag = current_account.featured_tags.find(params[:id])
  end

  def set_featured_tags
    @featured_tags = current_account.featured_tags
  end

  def featured_tag_params
    params.require(:featured_tag).permit(:name)
  end
end
