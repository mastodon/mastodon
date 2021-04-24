class Settings::FavouriteTagsController < Settings::BaseController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_favourite_tags, only: [:index, :create]
  before_action :set_favourite_tag, only: [:edit, :update, :destroy]

  def index
    @favourite_tag = FavouriteTag.new(tag: Tag.new, visibility: FavouriteTag.visibilities[:public])
  end

  def edit
    @favourite_tag
  end

  def create
    name = tag_params[:name].gsub(/\A#/, '')
    tag = Tag.find_or_initialize_by(name: name)
    @favourite_tag = FavouriteTag.new(account: @account, tag: tag, visibility: favourite_tag_params[:visibility], order: favourite_tag_params[:order])
    if @favourite_tag.save
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :index
    end
  end

  def update
    name = tag_params[:name].gsub(/\A#/, '')
    tag = Tag.find_or_initialize_by(name: name)
    if @favourite_tag.update(tag: tag, visibility: favourite_tag_params[:visibility], order: favourite_tag_params[:order])
      redirect_to settings_favourite_tags_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :edit
    end
  end

  def destroy
    @favourite_tag.destroy
    redirect_to settings_favourite_tags_path
  end

  private

  def tag_params
    params.require(:favourite_tag).require(:tag_attributes).permit(:id, :name)
  end

  def favourite_tag_params
    params.require(:favourite_tag).permit(:visibility, :order, { tag_attributes: [:id, :name] })
  end

  def set_account
    @account = current_user.account
  end

  def set_favourite_tag
    @favourite_tag = @account.favourite_tags.find(params[:id])
  end

  def set_favourite_tags
    @favourite_tags = @account.favourite_tags.with_order.includes(:tag)
  end
end
