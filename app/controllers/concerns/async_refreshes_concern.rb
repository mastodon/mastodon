# frozen_string_literal: true

module AsyncRefreshesConcern
  private

  def add_async_refresh_header(async_refresh, retry_seconds: 3)
    return unless async_refresh.running?

    value = "id=\"#{async_refresh.id}\", retry=#{retry_seconds}"
    value += ", result_count=#{async_refresh.result_count}" unless async_refresh.result_count.nil?

    response.headers['Mastodon-Async-Refresh'] = value
  end
end
