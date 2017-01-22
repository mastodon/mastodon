# frozen_string_literal: true

class Domain
    # helper object as there is currently no Domain model

    attr_accessor :name, :current_account
    
    def initialize(name, current_account)
        @name = name
        @current_account = current_account
    end
    
    def blocked
        @current_account.blocking_domain?(@name)
    end
    
    def blocked_globally
        DomainBlock.exists?(:domain => @name)
    end
end

class Api::V1::DomainsController < ApiController
    before_action -> { doorkeeper_authorize! :follow }
    before_action :require_user!

    respond_to :json

    def set_domain
        @domain = Domain.new params[:domain], current_account
    end

    def index
        domain_names = Account.select("DISTINCT domain").where("domain IS NOT NULL").pluck(:domain)
        @domains = domain_names.map {|x| Domain.new x, current_account}
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
