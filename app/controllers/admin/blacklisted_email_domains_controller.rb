# frozen_string_literal: true

module Admin
  class BlacklistedEmailDomainsController < BaseController
    before_action :set_blacklisted_email_domain, only: [:show, :destroy]

    def index
      @blacklisted_email_domains = BlacklistedEmailDomain.page(params[:page])
    end

    def new
      @blacklisted_email_domain = BlacklistedEmailDomain.new
    end

    def create
      @blacklisted_email_domain = BlacklistedEmailDomain.new(resource_params)

      if @blacklisted_email_domain.save
        redirect_to admin_blacklisted_email_domains_path, notice: I18n.t('admin.blacklisted_email_domains.created_msg')
      else
        render :new
      end
    end

    def destroy
      @blacklisted_email_domain.destroy
      redirect_to admin_blacklisted_email_domains_path, notice: I18n.t('admin.blacklisted_email_domains.destroyed_msg')
    end

    private

    def set_blacklisted_email_domain
      @blacklisted_email_domain = BlacklistedEmailDomain.find(params[:id])
    end

    def resource_params
      params.require(:blacklisted_email_domain).permit(:domain, :note)
    end
  end
end
