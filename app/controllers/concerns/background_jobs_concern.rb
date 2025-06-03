# frozen_string_literal: true

module BackgroundJobsConcern
  private

  def add_background_job_header_for(redis_key, retry_seconds: 3)
    job = BackgroundJob.new(redis_key)
    response.headers['Mastodon-Background-Job'] = "id=\"#{job.id}\", retry=#{retry_seconds}"
  end
end
