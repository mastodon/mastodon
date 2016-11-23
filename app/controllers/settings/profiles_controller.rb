# frozen_string_literal: true

class Settings::ProfilesController < ApplicationController
  layout 'auth'

  before_action :authenticate_user!
  before_action :set_account

  def show
  end

  def update
    if @account.update(account_params)
      redirect_to settings_profile_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render action: :show
    end
  end

  private

  def account_params
    p = params.require(:account).permit(:display_name, :note, :avatar, :header, :silenced)
    if p[:avatar]
        avatar = p[:avatar]
        # Change so Paperclip won't expose the actual filename
        avatar.original_filename = "media" + File.extname(avatar.original_filename)
    end
    if p[:header]
        header = p[:header]
        # Change so Paperclip won't expose the actual filename
        header.original_filename = "media" + File.extname(header.original_filename)
    end
    p
  end

  def set_account
    @account = current_user.account
  end
end
