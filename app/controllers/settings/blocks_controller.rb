# frozen_string_literal: true

class Settings::BlocksController < ApplicationController
    include DomainsHelper

    layout 'auth'

    before_action :authenticate_user!
    before_action :set_domains_from_db

    def show; end

    def update

        begin
            for i in 0 .. params[:domains].length - 1 do
                domain = params[:domains][i.to_s]
                if domain[:state] =~ (/^(false|f|no|n|0)$/i) then
                    # unblock if blocking
                    AccountUnblockDomainService.new.call(current_account, domain[:name])
                else
                    # block if not blocking
                    AccountBlockDomainService.new.call(current_account, domain[:name])
                end
            end
            redirect_to settings_blocks_path, notice: I18n.t('generic.changes_saved_msg')
        rescue
            render action: :show
        end
    end

end
