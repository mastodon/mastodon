# frozen_string_literal: true

class Settings::ProfilesController < ApplicationController
  layout 'auth'

  before_action :authenticate_user!
  before_action :set_account

  include ObfuscateFilename
  obfuscate_filename [:account, :avatar]
  obfuscate_filename [:account, :header]

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
    params.require(:account).permit(:display_name, :note, :avatar, :header, :silenced)
  end

  def set_account
    @account = current_user.account
  end
end
