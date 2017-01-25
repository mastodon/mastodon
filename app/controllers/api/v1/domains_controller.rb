# frozen_string_literal: true

class Api::V1::DomainsController < ApiController
    include DomainsHelper

    before_action -> { doorkeeper_authorize! :read }
    before_action :require_user!

    respond_to :json

    def index
        set_domains_from_db
        render action: :index
    end

    def block
        params[:target_domains].each { |x| AccountBlockDomainService.new.call(current_account, x) }
        @domains = params[:target_domains].map {|x| Domain.new x, current_account}
        render action: :index
    end

    def unblock
        params[:target_domains].each { |x| AccountUnblockDomainService.new.call(current_account, x) }
        @domains = params[:target_domains].map {|x| Domain.new x, current_account}
        render action: :index
    end
end
