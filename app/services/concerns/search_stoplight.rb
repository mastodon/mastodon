# frozen_string_literal: true

module SearchStoplight
  STOPLIGHT_COOL_OFF_TIME = 5.minutes.seconds
  STOPLIGHT_THRESHOLD = 10

  def elastic_stoplight_wrapper
    Stoplight(
      'search:elasticsearch',
      cool_off_time: STOPLIGHT_COOL_OFF_TIME,
      threshold: STOPLIGHT_THRESHOLD,
      tracked_errors: [Faraday::ConnectionFailed, Errno::ENETUNREACH, OpenSSL::SSL::SSLError, Elastic::Transport::Transport::Error]
    )
  end
end
