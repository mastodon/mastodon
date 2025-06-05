# frozen_string_literal: true

module AsyncRefreshesConcern
  private

  def add_async_refresh_header(async_refresh, retry_seconds: 3)
    return unless async_refresh.running?

    response.headers['Mastodon-Async-Refresh'] = "id=\"#{async_refresh.id}\", retry=#{retry_seconds}"
  end
end
