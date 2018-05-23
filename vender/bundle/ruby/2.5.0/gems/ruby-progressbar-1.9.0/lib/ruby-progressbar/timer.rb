require 'ruby-progressbar/time'

class   ProgressBar
class   Timer
  attr_accessor :started_at,
                :stopped_at

  def initialize(options = {})
    self.time = options[:time] || Time.new
  end

  def start
    self.started_at = stopped? ? time.now - (stopped_at - started_at) : time.now
    self.stopped_at = nil
  end

  def stop
    return unless started?

    self.stopped_at = time.now
  end

  def pause
    stop
  end

  def resume
    start
  end

  def started?
    started_at
  end

  def stopped?
    stopped_at
  end

  def reset
    self.started_at = nil
    self.stopped_at = nil
  end

  def reset?
    !started_at
  end

  def restart
    reset
    start
  end

  def elapsed_seconds
    ((stopped_at || time.now) - started_at)
  end

  def elapsed_whole_seconds
    elapsed_seconds.floor
  end

  def divide_seconds(seconds)
    hours, seconds   = seconds.divmod(3600)
    minutes, seconds = seconds.divmod(60)

    [hours, minutes, seconds]
  end

  protected

  attr_accessor :time
end
end
