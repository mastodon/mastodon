# frozen_string_literal: true

module Settings
  class PicturesController < BaseController
    before_action :authenticate_user!
    before_action :set_account
    before_action :set_picture

    def destroy
      if valid_picture
        account_params = {
          @picture => nil,
          (@picture + '_remote_url') => nil,
        }

        msg = UpdateAccountService.new.call(@account, account_params) ? I18n.t('generic.changes_saved_msg') : nil
        redirect_to settings_profile_path, notice: msg, status: 303
      else
        bad_request
      end
    end

    private

    def set_account
      @account = current_account
    end

    def set_picture
      @picture = params[:id]
    end

    def valid_picture
      @picture == 'avatar' || @picture == 'header'
    end
  end
end
