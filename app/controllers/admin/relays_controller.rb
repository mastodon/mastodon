# frozen_string_literal: true

module Admin
  class RelaysController < BaseController
    before_action :set_relay, except: [:index, :new, :create]
    before_action :warn_signatures_not_enabled!, only: [:new, :create, :enable]

    def index
      authorize :relay, :update?
      @relays = Relay.all
    end

    def new
      authorize :relay, :update?
      @relay = Relay.new
    end

    def create
      authorize :relay, :update?

      @relay = Relay.new(resource_params)

      if @relay.save
        log_action :create, @relay
        @relay.enable!
        redirect_to admin_relays_path
      else
        render :new
      end
    end

    def destroy
      authorize :relay, :update?
      @relay.destroy
      log_action :destroy, @relay
      redirect_to admin_relays_path
    end

    def enable
      authorize :relay, :update?
      @relay.enable!
      log_action :enable, @relay
      redirect_to admin_relays_path
    end

    def disable
      authorize :relay, :update?
      @relay.disable!
      log_action :disable, @relay
      redirect_to admin_relays_path
    end

    private

    def set_relay
      @relay = Relay.find(params[:id])
    end

    def resource_params
      params.require(:relay).permit(:inbox_url)
    end

    def warn_signatures_not_enabled!
      flash.now[:error] = I18n.t('admin.relays.signatures_not_enabled') if authorized_fetch_mode?
    end
  end
end
