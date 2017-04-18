# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    def index
      @instances = ordered_instances.page(params[:page])
    end

    private

    def ordered_instances
      Account.
        where.not(domain: nil).
        group(:domain).
        select(:domain, "COUNT(*) AS accounts_count").
        order('accounts_count desc')
    end
  end
end
