# frozen_string_literal: true

module Settings
  class PicturesController < BaseController
    before_action :set_account
    before_action :set_picture

    def destroy
      if valid_picture?
        if UpdateAccountService.new.call(@account, { @picture => nil, "#{@picture}_remote_url" => '' })
          ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
          redirect_to settings_profile_path, notice: I18n.t('generic.changes_saved_msg'), status: 303
        else
          redirect_to settings_profile_path
        end
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

    def valid_picture?
      %w(avatar header).include?(@picture)
    end
  end
end
