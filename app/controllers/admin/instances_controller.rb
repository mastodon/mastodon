# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, except: :index
    before_action :set_exhausted_deliveries_days, only: :show

    def index
      authorize :instance, :index?
    end

    def show
      authorize :instance, :show?
    end

    def clear_delivery_errors
      authorize :delivery, :clear_delivery_errors?

      @instance.delivery_failure_tracker.clear_failures!
      redirect_to admin_instance_path(@instance.domain)
    end

    def restart_delivery
      authorize :delivery, :restart_delivery?

      last_unavailable_domain = unavailable_domain

      if last_unavailable_domain.present?
        @instance.delivery_failure_tracker.track_success!
        log_action :destroy, last_unavailable_domain
      end

      redirect_to admin_instance_path(@instance.domain)
    end

    def stop_delivery
      authorize :delivery, :stop_delivery?

      UnavailableDomain.create(domain: @instance.domain)
      log_action :create, unavailable_domain
      redirect_to admin_instance_path(@instance.domain)
    end

    private

    def set_instance
      @instance = Instance.find(params[:id])
    end

    def set_exhausted_deliveries_days
      @exhausted_deliveries_days = @instance.delivery_failure_tracker.exhausted_deliveries_days
    end

    def set_instances
      @instances = filtered_instances.page(params[:page])
      warning_domains_map = DeliveryFailureTracker.warning_domains_map

      @instances.each do |instance|
        instance.failure_days = warning_domains_map[instance.domain]
      end
    end

    def unavailable_domain
      UnavailableDomain.find_by(domain: @instance.domain)
    end

    def filtered_instances
      InstanceFilter.new(whitelist_mode? ? { allowed: true } : filter_params).results
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
