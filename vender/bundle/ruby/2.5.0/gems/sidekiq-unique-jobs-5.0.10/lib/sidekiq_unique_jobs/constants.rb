# frozen_string_literal: true

module SidekiqUniqueJobs
  ARGS_KEY ||= 'args'
  AT_KEY ||= 'at'
  CLASS_KEY ||= 'class'
  JID_KEY ||= 'jid'
  LOG_DUPLICATE_KEY ||= 'log_duplicate_payload'
  QUEUE_KEY ||= 'queue'
  HASH_KEY ||= 'uniquejobs'
  QUEUE_LOCK_TIMEOUT_KEY ||= 'unique_expiration'
  RUN_LOCK_TIMEOUT_KEY ||= 'run_lock_expiration'
  TESTING_CONSTANT ||= 'Testing'
  UNIQUE_KEY ||= 'unique'
  UNIQUE_LOCK_KEY ||= 'unique_lock'
  UNIQUE_ARGS_KEY ||= 'unique_args'
  UNIQUE_PREFIX_KEY ||= 'unique_prefix'
  UNIQUE_DIGEST_KEY ||= 'unique_digest'
  UNIQUE_ON_ALL_QUEUES_KEY ||= 'unique_on_all_queues'
  UNIQUE_ACROSS_WORKERS_KEY ||= 'unique_across_workers'
  UNIQUE_ARGS_ENABLED_KEY ||= 'unique_args_enabled'
end
