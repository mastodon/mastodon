class Settings::FavouriteTagsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_favourite_tag, only: [:destroy]

  def index
    @favourite_tag = FavouriteTag.new(tag: Tag.new, visibility: FavouriteTag.visibilities[:public])
  end

  def create
    name = tag_params[:name].gsub(/\A#/, '')
    tag = Tag.find_or_initialize_by(name: name)
    @favourite_tag = FavouriteTag.new(account: @account, tag: tag, visibility: visibility_params[:visibility])
    if @favourite_tag.save
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :index
    end
  end

  def destroy
    @favourite_tag.destroy
    redirect_to settings_favourite_tags_path
  end

  private

  def tag_params
    params.require(:favourite_tag).require(:tag_attributes).permit(:name)
  end

  def visibility_params
    params.require(:favourite_tag).permit(:visibility)
  end

  def set_account
    @account = current_user.account
  end

  def set_favourite_tag
    @favourite_tag = @account.favourite_tags.find(params[:id])
  end
end
