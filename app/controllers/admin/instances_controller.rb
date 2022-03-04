# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, except: :index

    def index
      authorize :instance, :index?
      preload_delivery_failures!
    end

    def show
      authorize :instance, :show?
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
    end

    def destroy
      authorize :instance, :destroy?
      Admin::DomainPurgeWorker.perform_async(@instance.domain)
      log_action :destroy, @instance
      redirect_to admin_instances_path, notice: I18n.t('admin.instances.destroyed_msg', domain: @instance.domain)
    end

    def clear_delivery_errors
      authorize :delivery, :clear_delivery_errors?
      @instance.delivery_failure_tracker.clear_failures!
      redirect_to admin_instance_path(@instance.domain)
    end

    def restart_delivery
      authorize :delivery, :restart_delivery?

      if @instance.unavailable?
        @instance.delivery_failure_tracker.track_success!
        log_action :destroy, @instance.unavailable_domain
      end

      redirect_to admin_instance_path(@instance.domain)
    end

    def stop_delivery
      authorize :delivery, :stop_delivery?
      unavailable_domain = UnavailableDomain.create!(domain: @instance.domain)
      log_action :create, unavailable_domain
      redirect_to admin_instance_path(@instance.domain)
    end

    private

    def set_instance
      @instance = Instance.find(params[:id])
    end

    def set_instances
      @instances = filtered_instances.page(params[:page])
    end

    def preload_delivery_failures!
      warning_domains_map = DeliveryFailureTracker.warning_domains_map

      @instances.each do |instance|
        instance.failure_days = warning_domains_map[instance.domain]
      end
    end

    def filtered_instances
      InstanceFilter.new(whitelist_mode? ? { allowed: true } : filter_params).results
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
