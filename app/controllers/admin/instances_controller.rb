# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    def index
      @instances = ordered_instances.page(params[:page])
    end

    def show
      @instance = InstancePresenter.new(domain)
    end

    private

    def ordered_instances
      InstancePresenter.all
    end

    def domain
      params[:id]
    end
  end
end
