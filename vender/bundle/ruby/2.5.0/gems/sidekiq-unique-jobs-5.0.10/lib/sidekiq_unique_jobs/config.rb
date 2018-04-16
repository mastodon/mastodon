# frozen_string_literal: true

module SidekiqUniqueJobs
  class Config < OpenStruct
    def inline_testing_enabled?
      testing_enabled? && Sidekiq::Testing.inline?
    end

    def mocking?
      redis_test_mode.to_sym == :mock
    end

    def testing_enabled?
      Sidekiq.const_defined?(TESTING_CONSTANT, false) && Sidekiq::Testing.enabled?
    end
  end
end
