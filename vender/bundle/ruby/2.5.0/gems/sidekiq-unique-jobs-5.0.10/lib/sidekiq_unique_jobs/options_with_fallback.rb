# frozen_string_literal: true

module SidekiqUniqueJobs
  module OptionsWithFallback
    def self.included(base)
      base.send(:extend, SidekiqUniqueJobs::OptionsWithFallback::ClassMethods)
    end

    def unique_enabled?
      options[UNIQUE_KEY] || item[UNIQUE_KEY]
    end

    def unique_disabled?
      !unique_enabled?
    end

    def log_duplicate_payload?
      options[LOG_DUPLICATE_KEY] || item[LOG_DUPLICATE_KEY]
    end

    def lock
      @lock = lock_class.new(item)
    end

    def lock_class
      lock_cache[unique_lock.to_sym] ||= Object.const_get("SidekiqUniqueJobs::Lock::#{unique_lock.to_s.classify}")
    end

    def unique_lock
      @unique_lock ||=
        if options.key?(UNIQUE_KEY) && options[UNIQUE_KEY].to_s == 'true'
          warn('unique: true is no longer valid. Please set it to the type of lock required like: ' \
               '`unique: :until_executed`')
          options[UNIQUE_LOCK_KEY] || SidekiqUniqueJobs.default_lock
        else
          lock_type || SidekiqUniqueJobs.default_lock
        end
    end

    def lock_type
      lock_type_from(options) || lock_type_from(item)
    end

    def lock_type_from(hash, key = UNIQUE_KEY)
      return nil if hash[key].is_a?(TrueClass)
      hash[key]
    end

    def lock_cache
      self.class.lock_cache
    end

    def lock_cache=(obj)
      self.class.lock_cache = obj
    end

    def options
      @options ||= worker_class.get_sidekiq_options if worker_class.respond_to?(:get_sidekiq_options)
      @options ||= Sidekiq.default_worker_options
      @options ||= {}
      @options &&= @options.stringify_keys
    end

    module ClassMethods
      def lock_cache
        @lock_cache ||= {}
      end

      def lock_cache=(obj)
        @lock_cache = obj
      end
    end
  end
end
