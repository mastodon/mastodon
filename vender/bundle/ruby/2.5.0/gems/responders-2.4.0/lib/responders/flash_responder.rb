module Responders
  # Responder to automatically set flash messages based on I18n API. It checks for
  # message based on the current action, but also allows defaults to be set, using
  # the following order:
  #
  #   flash.controller_name.action_name.status
  #   flash.actions.action_name.status
  #
  # So, if you have a CarsController, create action, it will check for:
  #
  #   flash.cars.create.status
  #   flash.actions.create.status
  #
  # The statuses by default are :notice (when the object can be created, updated
  # or destroyed with success) and :alert (when the object cannot be created
  # or updated).
  #
  # On I18n, the resource_name given is available as interpolation option,
  # this means you can set:
  #
  #   flash:
  #     actions:
  #       create:
  #         notice: "Hooray! %{resource_name} was successfully created!"
  #
  # But sometimes, flash messages are not that simple. Going back
  # to cars example, you might want to say the brand of the car when it's
  # updated. Well, that's easy also:
  #
  #   flash:
  #     cars:
  #       update:
  #         notice: "Hooray! You just tuned your %{car_brand}!"
  #
  # Since :car_name is not available for interpolation by default, you have
  # to overwrite `flash_interpolation_options` in your controller.
  #
  #   def flash_interpolation_options
  #     { :car_brand => @car.brand }
  #   end
  #
  # Then you will finally have:
  #
  #   'Hooray! You just tuned your Aston Martin!'
  #
  # If your controller is namespaced, for example Admin::CarsController,
  # the messages will be checked in the following order:
  #
  #   flash.admin.cars.create.status
  #   flash.admin.actions.create.status
  #   flash.cars.create.status
  #   flash.actions.create.status
  #
  # You can also have flash messages with embedded HTML. Just create a scope that
  # ends with <tt>_html</tt> as the scopes below:
  #
  #   flash.actions.create.notice_html
  #   flash.cars.create.notice_html
  #
  # == Options
  #
  # FlashResponder also accepts some options through respond_with API.
  #
  # * :flash - When set to false, no flash message is set.
  #
  #     respond_with(@user, :flash => true)
  #
  # * :notice - Supply the message to be set if the record has no errors.
  # * :alert - Supply the message to be set if the record has errors.
  #
  #     respond_with(@user, :notice => "Hooray! Welcome!", :alert => "Woot! You failed.")
  #
  # * :flash_now - Sets the flash message using flash.now. Accepts true, :on_failure or :on_sucess.
  #
  # == Configure status keys
  #
  # As said previously, FlashResponder by default use :notice and :alert
  # keys. You can change that by setting the status_keys:
  #
  #   Responders::FlashResponder.flash_keys = [ :success, :failure ]
  #
  # However, the options :notice and :alert to respond_with are kept :notice
  # and :alert.
  #
  module FlashResponder
    class << self
      attr_accessor :flash_keys, :namespace_lookup, :helper
    end

    self.flash_keys = [ :notice, :alert ]
    self.namespace_lookup = false
    self.helper = Object.new.extend(
      ActionView::Helpers::TranslationHelper,
      ActionView::Helpers::TagHelper
    )

    def initialize(controller, resources, options={})
      super
      @flash     = options.delete(:flash)
      @notice    = options.delete(:notice)
      @alert     = options.delete(:alert)
      @flash_now = options.delete(:flash_now) { :on_failure }
    end

    def to_html
      set_flash_message! if set_flash_message?
      super
    end

    def to_js
      set_flash_message! if set_flash_message?
      defined?(super) ? super : to_format
    end

  protected

    def set_flash_message!
      if has_errors?
        status = Responders::FlashResponder.flash_keys.last
        set_flash(status, @alert)
      else
        status = Responders::FlashResponder.flash_keys.first
        set_flash(status, @notice)
      end

      return if controller.flash[status].present?

      options = mount_i18n_options(status)
      message = Responders::FlashResponder.helper.t options[:default].shift, options
      set_flash(status, message)
    end

    def set_flash(key, value)
      return if value.blank?
      flash = controller.flash
      flash = flash.now if set_flash_now?
      flash[key] ||= value
    end

    def set_flash_now?
      @flash_now == true || format == :js ||
        (default_action && (has_errors? ? @flash_now == :on_failure : @flash_now == :on_success))
    end

    def set_flash_message? #:nodoc:
      !get? && @flash != false
    end

    def mount_i18n_options(status) #:nodoc:
      options = {
        :default => flash_defaults_by_namespace(status),
        :resource_name => resource_name,
        :downcase_resource_name => resource_name.downcase
      }

      controller_options = controller_interpolation_options
      if controller_options
        options.merge!(controller_options)
      end

      options
    end

    def controller_interpolation_options
      if controller.respond_to?(:flash_interpolation_options, true)
        controller.send(:flash_interpolation_options)
      elsif controller.respond_to?(:interpolation_options, true)
        ActiveSupport::Deprecation.warn("[responders] `#{controller.class}#interpolation_options` is deprecated, please rename it to `flash_interpolation_options`.")
        controller.send(:interpolation_options)
      end
    end

    def resource_name
      if resource.class.respond_to?(:model_name)
        resource.class.model_name.human
      else
        resource.class.name.underscore.humanize
      end
    end

    def flash_defaults_by_namespace(status) #:nodoc:
      defaults = []
      slices   = controller.controller_path.split('/')
      lookup   = Responders::FlashResponder.namespace_lookup

      begin
        controller_scope = :"flash.#{slices.fill(controller.controller_name, -1).join('.')}.#{controller.action_name}.#{status}"

        actions_scope = lookup ? slices.fill('actions', -1).join('.') : :actions
        actions_scope = :"flash.#{actions_scope}.#{controller.action_name}.#{status}"

        defaults << :"#{controller_scope}_html"
        defaults << controller_scope

        defaults << :"#{actions_scope}_html"
        defaults << actions_scope

        slices.shift
      end while slices.size > 0 && lookup

      defaults << ""
    end
  end
end
