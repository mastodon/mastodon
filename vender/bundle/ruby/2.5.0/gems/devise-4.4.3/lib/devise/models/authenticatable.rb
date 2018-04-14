# frozen_string_literal: true

require 'active_model/version'
require 'devise/hooks/activatable'
require 'devise/hooks/csrf_cleaner'

module Devise
  module Models
    # Authenticatable module. Holds common settings for authentication.
    #
    # == Options
    #
    # Authenticatable adds the following options to devise_for:
    #
    #   * +authentication_keys+: parameters used for authentication. By default [:email].
    #
    #   * +http_authentication_key+: map the username passed via HTTP Auth to this parameter. Defaults to
    #     the first element in +authentication_keys+.
    #
    #   * +request_keys+: parameters from the request object used for authentication.
    #     By specifying a symbol (which should be a request method), it will automatically be
    #     passed to find_for_authentication method and considered in your model lookup.
    #
    #     For instance, if you set :request_keys to [:subdomain], :subdomain will be considered
    #     as key on authentication. This can also be a hash where the value is a boolean specifying
    #     if the value is required or not.
    #
    #   * +http_authenticatable+: if this model allows http authentication. By default false.
    #     It also accepts an array specifying the strategies that should allow http.
    #
    #   * +params_authenticatable+: if this model allows authentication through request params. By default true.
    #     It also accepts an array specifying the strategies that should allow params authentication.
    #
    #   * +skip_session_storage+: By default Devise will store the user in session.
    #     By default is set to skip_session_storage: [:http_auth].
    #
    # == active_for_authentication?
    #
    # After authenticating a user and in each request, Devise checks if your model is active by
    # calling model.active_for_authentication?. This method is overwritten by other devise modules. For instance,
    # :confirmable overwrites .active_for_authentication? to only return true if your model was confirmed.
    #
    # You can overwrite this method yourself, but if you do, don't forget to call super:
    #
    #   def active_for_authentication?
    #     super && special_condition_is_valid?
    #   end
    #
    # Whenever active_for_authentication? returns false, Devise asks the reason why your model is inactive using
    # the inactive_message method. You can overwrite it as well:
    #
    #   def inactive_message
    #     special_condition_is_valid? ? super : :special_condition_is_not_valid
    #   end
    #
    module Authenticatable
      extend ActiveSupport::Concern

      BLACKLIST_FOR_SERIALIZATION = [:encrypted_password, :reset_password_token, :reset_password_sent_at,
        :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
        :last_sign_in_ip, :password_salt, :confirmation_token, :confirmed_at, :confirmation_sent_at,
        :remember_token, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at]

      included do
        class_attribute :devise_modules, instance_writer: false
        self.devise_modules ||= []

        before_validation :downcase_keys
        before_validation :strip_whitespace
      end

      def self.required_fields(klass)
        []
      end

      # Check if the current object is valid for authentication. This method and
      # find_for_authentication are the methods used in a Warden::Strategy to check
      # if a model should be signed in or not.
      #
      # However, you should not overwrite this method, you should overwrite active_for_authentication?
      # and inactive_message instead.
      def valid_for_authentication?
        block_given? ? yield : true
      end

      def unauthenticated_message
        :invalid
      end

      def active_for_authentication?
        true
      end

      def inactive_message
        :inactive
      end

      def authenticatable_salt
      end

      # Redefine serializable_hash in models for more secure defaults.
      # By default, it removes from the serializable model all attributes that
      # are *not* accessible. You can remove this default by using :force_except
      # and passing a new list of attributes you want to exempt. All attributes
      # given to :except will simply add names to exempt to Devise internal list.
      def serializable_hash(options = nil)
        options = options.try(:dup) || {}
        options[:except] = Array(options[:except])

        if options[:force_except]
          options[:except].concat Array(options[:force_except])
        else
          options[:except].concat BLACKLIST_FOR_SERIALIZATION
        end

        super(options)
      end

      # Redefine inspect using serializable_hash, to ensure we don't accidentally
      # leak passwords into exceptions.
      def inspect
        inspection = serializable_hash.collect do |k,v|
          "#{k}: #{respond_to?(:attribute_for_inspect) ? attribute_for_inspect(k) : v.inspect}"
        end
        "#<#{self.class} #{inspection.join(", ")}>"
      end

      protected

      def devise_mailer
        Devise.mailer
      end

      # This is an internal method called every time Devise needs
      # to send a notification/mail. This can be overridden if you
      # need to customize the e-mail delivery logic. For instance,
      # if you are using a queue to deliver e-mails (delayed job,
      # sidekiq, resque, etc), you must add the delivery to the queue
      # just after the transaction was committed. To achieve this,
      # you can override send_devise_notification to store the
      # deliveries until the after_commit callback is triggered:
      #
      #     class User
      #       devise :database_authenticatable, :confirmable
      #
      #       after_commit :send_pending_notifications
      #
      #       protected
      #
      #       def send_devise_notification(notification, *args)
      #         # If the record is new or changed then delay the
      #         # delivery until the after_commit callback otherwise
      #         # send now because after_commit will not be called.
      #         if new_record? || changed?
      #           pending_notifications << [notification, args]
      #         else
      #           message = devise_mailer.send(notification, self, *args)
      #           Remove once we move to Rails 4.2+ only.
      #           if message.respond_to?(:deliver_now)
      #             message.deliver_now
      #           else
      #             message.deliver
      #           end
      #         end
      #       end
      #
      #       def send_pending_notifications
      #         pending_notifications.each do |notification, args|
      #           message = devise_mailer.send(notification, self, *args)
      #           Remove once we move to Rails 4.2+ only.
      #           if message.respond_to?(:deliver_now)
      #             message.deliver_now
      #           else
      #             message.deliver
      #           end
      #         end
      #
      #         # Empty the pending notifications array because the
      #         # after_commit hook can be called multiple times which
      #         # could cause multiple emails to be sent.
      #         pending_notifications.clear
      #       end
      #
      #       def pending_notifications
      #         @pending_notifications ||= []
      #       end
      #     end
      #
      def send_devise_notification(notification, *args)
        message = devise_mailer.send(notification, self, *args)
        # Remove once we move to Rails 4.2+ only.
        if message.respond_to?(:deliver_now)
          message.deliver_now
        else
          message.deliver
        end
      end

      def downcase_keys
        self.class.case_insensitive_keys.each { |k| apply_to_attribute_or_variable(k, :downcase) }
      end

      def strip_whitespace
        self.class.strip_whitespace_keys.each { |k| apply_to_attribute_or_variable(k, :strip) }
      end

      def apply_to_attribute_or_variable(attr, method)
        if self[attr]
          self[attr] = self[attr].try(method)

        # Use respond_to? here to avoid a regression where globally
        # configured strip_whitespace_keys or case_insensitive_keys were
        # attempting to strip or downcase when a model didn't have the
        # globally configured key.
        elsif respond_to?(attr) && respond_to?("#{attr}=")
          new_value = send(attr).try(method)
          send("#{attr}=", new_value)
        end
      end

      module ClassMethods
        Devise::Models.config(self, :authentication_keys, :request_keys, :strip_whitespace_keys,
          :case_insensitive_keys, :http_authenticatable, :params_authenticatable, :skip_session_storage,
          :http_authentication_key)

        def serialize_into_session(record)
          [record.to_key, record.authenticatable_salt]
        end

        def serialize_from_session(key, salt)
          record = to_adapter.get(key)
          record if record && record.authenticatable_salt == salt
        end

        def params_authenticatable?(strategy)
          params_authenticatable.is_a?(Array) ?
            params_authenticatable.include?(strategy) : params_authenticatable
        end

        def http_authenticatable?(strategy)
          http_authenticatable.is_a?(Array) ?
            http_authenticatable.include?(strategy) : http_authenticatable
        end

        # Find first record based on conditions given (ie by the sign in form).
        # This method is always called during an authentication process but
        # it may be wrapped as well. For instance, database authenticatable
        # provides a `find_for_database_authentication` that wraps a call to
        # this method. This allows you to customize both database authenticatable
        # or the whole authenticate stack by customize `find_for_authentication.`
        #
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        # Example:
        #
        #   def self.find_for_authentication(tainted_conditions)
        #     find_first_by_auth_conditions(tainted_conditions, active: true)
        #   end
        #
        # Finally, notice that Devise also queries for users in other scenarios
        # besides authentication, for example when retrieving a user to send
        # an e-mail for password reset. In such cases, find_for_authentication
        # is not called.
        def find_for_authentication(tainted_conditions)
          find_first_by_auth_conditions(tainted_conditions)
        end

        def find_first_by_auth_conditions(tainted_conditions, opts={})
          to_adapter.find_first(devise_parameter_filter.filter(tainted_conditions).merge(opts))
        end

        # Find or initialize a record setting an error if it can't be found.
        def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
          find_or_initialize_with_errors([attribute], { attribute => value }, error)
        end

        # Find or initialize a record with group of attributes based on a list of required attributes.
        def find_or_initialize_with_errors(required_attributes, attributes, error=:invalid) #:nodoc:
          attributes = if attributes.respond_to? :permit!
            attributes.slice(*required_attributes).permit!.to_h.with_indifferent_access
          else
            attributes.with_indifferent_access.slice(*required_attributes)
          end
          attributes.delete_if { |key, value| value.blank? }

          if attributes.size == required_attributes.size
            record = find_first_by_auth_conditions(attributes)
          end

          unless record
            record = new

            required_attributes.each do |key|
              value = attributes[key]
              record.send("#{key}=", value)
              record.errors.add(key, value.present? ? error : :blank)
            end
          end

          record
        end

        protected

        def devise_parameter_filter
          @devise_parameter_filter ||= Devise::ParameterFilter.new(case_insensitive_keys, strip_whitespace_keys)
        end
      end
    end
  end
end
