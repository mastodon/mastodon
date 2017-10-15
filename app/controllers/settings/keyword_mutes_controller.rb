# frozen_string_literal: true

class Settings::KeywordMutesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def index
    @keyword_mutes = paginated_keyword_mutes_for_account
  end

  def new
    @keyword_mute = keyword_mutes_for_account.build
  end

  private

  def set_account
    @account = current_user.account
  end

  def keyword_mutes_for_account
    KeywordMute.where(account: @account)
  end

  def paginated_keyword_mutes_for_account
    keyword_mutes_for_account.order(:keyword).page params[:page]
  end
end
