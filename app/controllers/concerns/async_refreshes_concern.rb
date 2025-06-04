# frozen_string_literal: true

module AsyncRefreshesConcern
  private

  def add_async_refresh_header_for(redis_key, retry_seconds: 3)
    job = AsyncRefresh.new(redis_key)
    response.headers['Mastodon-Async-Refresh'] = "id=\"#{job.id}\", retry=#{retry_seconds}"
  end
end
