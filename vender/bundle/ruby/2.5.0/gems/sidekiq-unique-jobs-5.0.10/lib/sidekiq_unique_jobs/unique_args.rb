# frozen_string_literal: true

require 'digest'
require 'sidekiq_unique_jobs/normalizer'

module SidekiqUniqueJobs
  # This class exists to be testable and the entire api should be considered private
  # rubocop:disable ClassLength
  class UniqueArgs
    CLASS_NAME = 'SidekiqUniqueJobs::UniqueArgs'
    extend Forwardable

    def_delegators :SidekiqUniqueJobs, :config, :worker_class_constantize
    def_delegators :Sidekiq, :logger

    def self.digest(item)
      new(item).unique_digest
    end

    def initialize(item)
      Sidekiq::Logging.with_context(CLASS_NAME) do
        @item = item
        @worker_class            ||= worker_class_constantize(@item[CLASS_KEY])
        @item[UNIQUE_PREFIX_KEY] ||= unique_prefix
        @item[UNIQUE_ARGS_KEY]     = unique_args(@item[ARGS_KEY])
        @item[UNIQUE_DIGEST_KEY]   = unique_digest
      end
    end

    def unique_digest
      @unique_digest ||= begin
        digest = Digest::MD5.hexdigest(Sidekiq.dump_json(digestable_hash))
        digest = "#{unique_prefix}:#{digest}"
        logger.debug { "#{__method__} : #{digestable_hash} into #{digest}" }
        digest
      end
    end

    def unique_prefix
      return config.unique_prefix unless sidekiq_worker_class?
      @worker_class.get_sidekiq_options[UNIQUE_PREFIX_KEY] || config.unique_prefix
    end

    def digestable_hash
      @item.slice(CLASS_KEY, QUEUE_KEY, UNIQUE_ARGS_KEY).tap do |hash|
        if unique_on_all_queues?
          logger.debug { "#{__method__} deleting queue: #{@item[QUEUE_KEY]}" }
          hash.delete(QUEUE_KEY)
        end
        if unique_across_workers?
          logger.debug { "#{__method__} deleting class: #{@item[CLASS_KEY]}" }
          hash.delete(CLASS_KEY)
        end
      end
    end

    def unique_args(args)
      if unique_args_enabled?
        filtered_args(args)
      else
        logger.debug { "#{__method__} : unique arguments disabled" }
        args
      end
    rescue NameError => ex
      logger.error "#{__method__}(#{args}) : failed with (#{ex.message})"
      logger.error ex

      raise if config.raise_unique_args_errors

      args
    end

    def unique_on_all_queues?
      return unless sidekiq_worker_class?
      @item[UNIQUE_ON_ALL_QUEUES_KEY] || @worker_class.get_sidekiq_options[UNIQUE_ON_ALL_QUEUES_KEY]
    end

    def unique_across_workers?
      return unless sidekiq_worker_class?
      @item[UNIQUE_ACROSS_WORKERS_KEY] || @worker_class.get_sidekiq_options[UNIQUE_ACROSS_WORKERS_KEY]
    end

    def unique_args_enabled?
      return unless sidekiq_worker_class?
      unique_args_method # && !unique_args_method.is_a?(Boolean)
    end

    def sidekiq_worker_class?
      if @worker_class.respond_to?(:get_sidekiq_options)
        true
      else
        logger.debug { "#{__method__} #{@worker_class} does not respond to :get_sidekiq_options" }
        nil
      end
    end

    # Filters unique arguments by proc or symbol
    # returns provided arguments for other configurations
    def filtered_args(args)
      return args if args.empty?
      json_args = Normalizer.jsonify(args)
      logger.debug { "#filtered_args #{args} => #{json_args}" }

      case unique_args_method
      when Proc
        filter_by_proc(json_args)
      when Symbol
        filter_by_symbol(json_args)
      else
        logger.debug { "#{__method__} arguments not filtered (using all arguments for uniqueness)" }
        json_args
      end
    end

    def filter_by_proc(args)
      if unique_args_method.nil?
        logger.warn { "#{__method__} : unique_args_method is nil. Returning (#{args})" }
        return args
      end

      filter_args = unique_args_method.call(args)
      logger.debug { "#{__method__} : #{args} -> #{filter_args}" }
      filter_args
    end

    def filter_by_symbol(args)
      unless @worker_class.respond_to?(unique_args_method)
        logger.warn do
          "#{__method__} : #{@worker_class} does not respond to #{unique_args_method}). Returning (#{args})"
        end
        return args
      end

      filter_args = @worker_class.send(unique_args_method, args)
      logger.debug { "#{__method__} : #{unique_args_method}(#{args}) => #{filter_args}" }
      filter_args
    rescue ArgumentError => ex
      logger.fatal "#{__method__} : #{@worker_class}'s #{unique_args_method} needs at least one argument"
      logger.fatal ex
      args
    end

    def unique_args_method
      @unique_args_method ||= @worker_class.get_sidekiq_options[UNIQUE_ARGS_KEY] if sidekiq_worker_class?
      @unique_args_method ||= :unique_args if @worker_class.respond_to?(:unique_args)
      @unique_args_method ||= Sidekiq.default_worker_options.stringify_keys[UNIQUE_ARGS_KEY]
    end
  end
end
