# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, except: :index

    LOGS_LIMIT = 5

    def index
      authorize :instance, :index?
      preload_delivery_failures!
    end

    def show
      authorize :instance, :show?
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
      @action_logs = Admin::ActionLogFilter.new(target_domain: @instance.domain).results.limit(LOGS_LIMIT)
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
      @instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain(params[:id]&.strip))
    end

    def set_instances
      # If we have a `status` in the query parameters, but it has no value or it
      # isn't a known status remove the status query parameter
      return redirect_to admin_instances_path filter_params.merge(status: nil) if params.include?(:status) && (params[:status].blank? || InstanceFilter::STATUSES.exclude?(params[:status]))

      # If we have `limited` in the query parameters, remove it and redirect to suspended:
      return redirect_to admin_instances_path filter_params.merge(status: :suspended) if params[:limited].present?

      # If we're in limited federation mode and have a status parameter, remove it:
      return redirect_to admin_instances_path filter_params.merge(status: nil) if limited_federation_mode? && params[:status].present?

      @instances = filtered_instances.page(params[:page])
    end

    def preload_delivery_failures!
      warning_domains_map = DeliveryFailureTracker.warning_domains_map(@instances.map(&:domain))

      @instances.each do |instance|
        instance.failure_days = warning_domains_map[instance.domain]
      end
    end

    def filtered_instances
      InstanceFilter.new(limited_federation_mode? ? filter_params.merge(status: :allowed) : filter_params).results
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
