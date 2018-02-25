# frozen_string_literal: true

class Mastodon::UniqueRetryJobMiddleware
  def call(_worker_class, item, _queue, _redis_pool)
    return if item['unique_retry'] && retried?(item)
    yield
  end

  private

  def retried?(item)
    # Use unique digest key of SidekiqUniqueJobs
    unique_key = SidekiqUniqueJobs::UNIQUE_DIGEST_KEY
    unique_digest = item[unique_key]
    class_name = item['class']
    retries = Sidekiq::RetrySet.new

    retries.any? { |job| job.item['class'] == class_name && job.item[unique_key] == unique_digest }
  end
end
