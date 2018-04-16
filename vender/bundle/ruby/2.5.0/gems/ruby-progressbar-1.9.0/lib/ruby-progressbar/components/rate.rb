class   ProgressBar
module  Components
class   Rate
  attr_accessor :rate_scale,
                :started_at,
                :stopped_at,
                :timer,
                :progress

  def initialize(options = {})
    self.rate_scale = options[:rate_scale] || lambda { |x| x }
    self.started_at = nil
    self.stopped_at = nil
    self.timer      = options[:timer]
    self.progress   = options[:progress]
  end

  private

  def rate_of_change(format_string = '%i')
    return 0 unless elapsed_seconds > 0

    format_string % scaled_rate
  end

  def rate_of_change_with_precision
    rate_of_change('%.2f')
  end

  def scaled_rate
    rate_scale.call(base_rate)
  end

  def base_rate
    progress.absolute / elapsed_seconds
  end

  def elapsed_seconds
    timer.elapsed_whole_seconds.to_f
  end
end
end
end
