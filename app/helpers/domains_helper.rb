# frozen_string_literal: true

module DomainsHelper
    class Domain
        # helper object as there is currently no Domain model

        attr_accessor :name, :current_account

        def initialize(name, current_account)
            @name = name
            @current_account = current_account
        end

        def blocked?
            @current_account.blocking_domain?(@name)
        end

        def blocked_globally?
            DomainBlock.exists?(:domain => @name)
        end
    end

    def set_domains_from_db
        domain_names = Account.select("DISTINCT domain").where("domain IS NOT NULL").order(:domain).pluck(:domain)
        @domains = domain_names.map {|x| Domain.new x, current_account}
    end
end
