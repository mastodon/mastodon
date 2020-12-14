# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, only: :show

    def index
      authorize :instance, :index?
    end

    def show
      authorize :instance, :show?
    end

    private

    def set_instance
      @instance = Instance.find(params[:id])
    end

    def set_instances
      @instances = filtered_instances.page(params[:page])
    end

    def filtered_instances
      InstanceFilter.new(whitelist_mode? ? { allowed: true } : filter_params).results
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
