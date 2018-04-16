# frozen_string_literal: true

require "devise/hooks/lockable"

module Devise
  module Models
    # Handles blocking a user access after a certain number of attempts.
    # Lockable accepts two different strategies to unlock a user after it's
    # blocked: email and time. The former will send an email to the user when
    # the lock happens, containing a link to unlock its account. The second
    # will unlock the user automatically after some configured time (ie 2.hours).
    # It's also possible to set up lockable to use both email and time strategies.
    #
    # == Options
    #
    # Lockable adds the following options to +devise+:
    #
    #   * +maximum_attempts+: how many attempts should be accepted before blocking the user.
    #   * +lock_strategy+: lock the user account by :failed_attempts or :none.
    #   * +unlock_strategy+: unlock the user account by :time, :email, :both or :none.
    #   * +unlock_in+: the time you want to lock the user after to lock happens. Only available when unlock_strategy is :time or :both.
    #   * +unlock_keys+: the keys you want to use when locking and unlocking an account
    #
    module Lockable
      extend  ActiveSupport::Concern

      delegate :lock_strategy_enabled?, :unlock_strategy_enabled?, to: "self.class"

      def self.required_fields(klass)
        attributes = []
        attributes << :failed_attempts if klass.lock_strategy_enabled?(:failed_attempts)
        attributes << :locked_at if klass.unlock_strategy_enabled?(:time)
        attributes << :unlock_token if klass.unlock_strategy_enabled?(:email)

        attributes
      end

      # Lock a user setting its locked_at to actual time.
      # * +opts+: Hash options if you don't want to send email
      #   when you lock access, you could pass the next hash
      #   `{ send_instructions: false } as option`.
      def lock_access!(opts = { })
        self.locked_at = Time.now.utc

        if unlock_strategy_enabled?(:email) && opts.fetch(:send_instructions, true)
          send_unlock_instructions
        else
          save(validate: false)
        end
      end

      # Unlock a user by cleaning locked_at and failed_attempts.
      def unlock_access!
        self.locked_at = nil
        self.failed_attempts = 0 if respond_to?(:failed_attempts=)
        self.unlock_token = nil  if respond_to?(:unlock_token=)
        save(validate: false)
      end

      # Verifies whether a user is locked or not.
      def access_locked?
        !!locked_at && !lock_expired?
      end

      # Send unlock instructions by email
      def send_unlock_instructions
        raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
        self.unlock_token = enc
        save(validate: false)
        send_devise_notification(:unlock_instructions, raw, {})
        raw
      end

      # Resend the unlock instructions if the user is locked.
      def resend_unlock_instructions
        if_access_locked { send_unlock_instructions }
      end

      # Overwrites active_for_authentication? from Devise::Models::Activatable for locking purposes
      # by verifying whether a user is active to sign in or not based on locked?
      def active_for_authentication?
        super && !access_locked?
      end

      # Overwrites invalid_message from Devise::Models::Authenticatable to define
      # the correct reason for blocking the sign in.
      def inactive_message
        access_locked? ? :locked : super
      end

      # Overwrites valid_for_authentication? from Devise::Models::Authenticatable
      # for verifying whether a user is allowed to sign in or not. If the user
      # is locked, it should never be allowed.
      def valid_for_authentication?
        return super unless persisted? && lock_strategy_enabled?(:failed_attempts)

        # Unlock the user if the lock is expired, no matter
        # if the user can login or not (wrong password, etc)
        unlock_access! if lock_expired?

        if super && !access_locked?
          true
        else
          increment_failed_attempts
          if attempts_exceeded?
            lock_access! unless access_locked?
          else
            save(validate: false)
          end
          false
        end
      end
      
      def increment_failed_attempts
        self.failed_attempts ||= 0
        self.failed_attempts += 1
      end

      def unauthenticated_message
        # If set to paranoid mode, do not show the locked message because it
        # leaks the existence of an account.
        if Devise.paranoid
          super
        elsif access_locked? || (lock_strategy_enabled?(:failed_attempts) && attempts_exceeded?)
          :locked
        elsif lock_strategy_enabled?(:failed_attempts) && last_attempt? && self.class.last_attempt_warning
          :last_attempt
        else
          super
        end
      end

      protected

        def attempts_exceeded?
          self.failed_attempts >= self.class.maximum_attempts
        end

        def last_attempt?
          self.failed_attempts == self.class.maximum_attempts - 1
        end

        # Tells if the lock is expired if :time unlock strategy is active
        def lock_expired?
          if unlock_strategy_enabled?(:time)
            locked_at && locked_at < self.class.unlock_in.ago
          else
            false
          end
        end

        # Checks whether the record is locked or not, yielding to the block
        # if it's locked, otherwise adds an error to email.
        def if_access_locked
          if access_locked?
            yield
          else
            self.errors.add(Devise.unlock_keys.first, :not_locked)
            false
          end
        end

      module ClassMethods
        # List of strategies that are enabled/supported if :both is used.
        BOTH_STRATEGIES = [:time, :email]

        # Attempt to find a user by its unlock keys. If a record is found, send new
        # unlock instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user's unlock keys
        def send_unlock_instructions(attributes={})
          lockable = find_or_initialize_with_errors(unlock_keys, attributes, :not_found)
          lockable.resend_unlock_instructions if lockable.persisted?
          lockable
        end

        # Find a user by its unlock token and try to unlock it.
        # If no user is found, returns a new user with an error.
        # If the user is not locked, creates an error for the user
        # Options must have the unlock_token
        def unlock_access_by_token(unlock_token)
          original_token = unlock_token
          unlock_token   = Devise.token_generator.digest(self, :unlock_token, unlock_token)

          lockable = find_or_initialize_with_error_by(:unlock_token, unlock_token)
          lockable.unlock_access! if lockable.persisted?
          lockable.unlock_token = original_token
          lockable
        end

        # Is the unlock enabled for the given unlock strategy?
        def unlock_strategy_enabled?(strategy)
          self.unlock_strategy == strategy ||
            (self.unlock_strategy == :both && BOTH_STRATEGIES.include?(strategy))
        end

        # Is the lock enabled for the given lock strategy?
        def lock_strategy_enabled?(strategy)
          self.lock_strategy == strategy
        end

        Devise::Models.config(self, :maximum_attempts, :lock_strategy, :unlock_strategy, :unlock_in, :unlock_keys, :last_attempt_warning)
      end
    end
  end
end
