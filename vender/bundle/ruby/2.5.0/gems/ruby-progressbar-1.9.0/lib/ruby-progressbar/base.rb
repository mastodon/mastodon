require 'forwardable'

class   ProgressBar
class   Base
  extend Forwardable

  def_delegators :output,
                 :clear,
                 :log,
                 :refresh

  def_delegators :progressable,
                 :progress,
                 :total

  def initialize(options = {})
    self.autostart    = options.fetch(:autostart,  true)
    self.autofinish   = options.fetch(:autofinish, true)
    self.finished     = false

    self.timer        = Timer.new(options)
    self.progressable = Progress.new(options)

    options           = options.merge(:timer    => timer,
                                      :progress => progressable)

    self.title_comp   = Components::Title.new(options)
    self.bar          = Components::Bar.new(options)
    self.percentage   = Components::Percentage.new(options)
    self.rate         = Components::Rate.new(options)
    self.time         = Components::Time.new(options)

    self.output       = Output.detect(options.merge(:bar => self))
    @format           = Format::String.new(output.resolve_format(options[:format]))

    start :at => options[:starting_at] if autostart
  end

  def start(options = {})
    timer.start
    update_progress(:start, options)
  end

  def finish
    return if finished?

    output.with_refresh do
      self.finished = true
      progressable.finish
      timer.stop
    end
  end

  def pause
    output.with_refresh { timer.pause } unless paused?
  end

  def stop
    output.with_refresh { timer.stop } unless stopped?
  end

  def resume
    output.with_refresh { timer.resume } if stopped?
  end

  def reset
    output.with_refresh do
      self.finished = false
      progressable.reset
      timer.reset
    end
  end

  def stopped?
    timer.stopped? || finished?
  end

  alias paused? stopped?

  def finished?
    finished || (autofinish && progressable.finished?)
  end

  def started?
    timer.started?
  end

  def decrement
    update_progress(:decrement)
  end

  def increment
    update_progress(:increment)
  end

  def progress=(new_progress)
    update_progress(:progress=, new_progress)
  end

  def total=(new_total)
    update_progress(:total=, new_total)
  end

  def progress_mark=(mark)
    output.refresh_with_format_change { bar.progress_mark = mark }
  end

  def remainder_mark=(mark)
    output.refresh_with_format_change { bar.remainder_mark = mark }
  end

  def title
    title_comp.title
  end

  def title=(title)
    output.refresh_with_format_change { title_comp.title = title }
  end

  def to_s(new_format = nil)
    self.format = new_format if new_format

    Format::Formatter.process(@format, output.length, self)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/LineLength
  def to_h
    {
      'output_stream'                       => output.__send__(:stream),
      'length'                              => output.length,
      'title'                               => title_comp.title,
      'progress_mark'                       => bar.progress_mark,
      'remainder_mark'                      => bar.remainder_mark,
      'progress'                            => progressable.progress,
      'total'                               => progressable.total,
      'percentage'                          => progressable.percentage_completed_with_precision.to_f,
      'elapsed_time_in_seconds'             => time.__send__(:timer).elapsed_seconds,
      'estimated_time_remaining_in_seconds' => time.__send__(:estimated_seconds_remaining),
      'base_rate_of_change'                 => rate.__send__(:base_rate),
      'scaled_rate_of_change'               => rate.__send__(:scaled_rate),
      'unknown_progress_animation_steps'    => bar.upa_steps,
      'throttle_rate'                       => output.__send__(:throttle).rate,
      'started?'                            => started?,
      'stopped?'                            => stopped?,
      'finished?'                           => finished?
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/LineLength

  def inspect
    "#<ProgressBar:#{progress}/#{total || 'unknown'}>"
  end

  def format=(other)
    output.refresh_with_format_change do
      @format = Format::String.new(other || output.default_format)
    end
  end

  alias format format=

  protected

  attr_accessor :output,
                :timer,
                :progressable,
                :title_comp,
                :bar,
                :percentage,
                :rate,
                :time,
                :autostart,
                :autofinish,
                :finished

  def update_progress(*args)
    output.with_refresh do
      progressable.__send__(*args)
      timer.stop if finished?
    end
  end
end
end
