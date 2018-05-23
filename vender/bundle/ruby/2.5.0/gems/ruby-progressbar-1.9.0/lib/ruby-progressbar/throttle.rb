class   ProgressBar
class   Throttle
  attr_accessor :rate,
                :started_at,
                :stopped_at,
                :timer

  def initialize(options = {})
    self.rate       = options[:throttle_rate] || 0.01
    self.started_at = nil
    self.stopped_at = nil
    self.timer      = options.fetch(:throttle_timer, Timer.new)
  end

  def choke(options = {})
    return unless !timer.started?                        ||
                  options.fetch(:force_update_if, false) ||
                  timer.elapsed_seconds >= rate

    timer.restart

    yield
  end
end
end
