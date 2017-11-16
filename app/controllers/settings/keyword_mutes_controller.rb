# frozen_string_literal: true

class Settings::KeywordMutesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :load_keyword_mute, only: [:edit, :update, :destroy]

  def index
    @keyword_mutes = paginated_keyword_mutes_for_account
  end

  def new
    @keyword_mute = keyword_mutes_for_account.build
  end

  def create
    @keyword_mute = keyword_mutes_for_account.create(keyword_mute_params)

    if @keyword_mute.persisted?
      redirect_to settings_keyword_mutes_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :new
    end
  end

  def update
    if @keyword_mute.update(keyword_mute_params)
      redirect_to settings_keyword_mutes_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :edit
    end
  end

  def destroy
    @keyword_mute.destroy!

    redirect_to settings_keyword_mutes_path, notice: I18n.t('generic.changes_saved_msg')
  end

  def destroy_all
    keyword_mutes_for_account.delete_all

    redirect_to settings_keyword_mutes_path, notice: I18n.t('generic.changes_saved_msg')
  end

  private

  def keyword_mutes_for_account
    Glitch::KeywordMute.where(account: current_account)
  end

  def load_keyword_mute
    @keyword_mute = keyword_mutes_for_account.find(params[:id])
  end

  def keyword_mute_params
    params.require(:keyword_mute).permit(:keyword, :whole_word)
  end

  def paginated_keyword_mutes_for_account
    keyword_mutes_for_account.order(:keyword).page params[:page]
  end
end
