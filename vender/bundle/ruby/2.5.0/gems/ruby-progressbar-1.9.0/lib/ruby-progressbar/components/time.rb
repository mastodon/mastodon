###
# OOB = 'Out of Bounds'
#
class   ProgressBar
module  Components
class   Time
  TIME_FORMAT            = '%02d:%02d:%02d'.freeze
  OOB_TIME_FORMATS       = [:unknown, :friendly, nil].freeze
  OOB_LIMIT_IN_HOURS     = 99
  OOB_UNKNOWN_TIME_TEXT  = '??:??:??'.freeze
  OOB_FRIENDLY_TIME_TEXT = '> 4 Days'.freeze
  NO_TIME_ELAPSED_TEXT   = '--:--:--'.freeze
  ESTIMATED_LABEL        = ' ETA'.freeze
  ELAPSED_LABEL          = 'Time'.freeze

  def initialize(options = {})
    self.out_of_bounds_time_format = options[:out_of_bounds_time_format]
    self.timer                     = options[:timer]
    self.progress                  = options[:progress]
  end

  def estimated_with_label
    "#{ESTIMATED_LABEL}: #{estimated}"
  end

  def elapsed_with_label
    "#{ELAPSED_LABEL}: #{elapsed}"
  end

  protected

  def estimated_with_no_oob
    self.out_of_bounds_time_format = nil

    estimated_with_elapsed_fallback
  end

  def estimated_with_unknown_oob
    self.out_of_bounds_time_format = :unknown

    estimated_with_elapsed_fallback
  end

  def estimated_with_friendly_oob
    self.out_of_bounds_time_format = :friendly

    estimated_with_elapsed_fallback
  end

  attr_reader   :out_of_bounds_time_format
  attr_accessor :timer,
                :progress

  def out_of_bounds_time_format=(format)
    unless OOB_TIME_FORMATS.include? format
      fail 'Invalid Out Of Bounds time format.  Valid formats are ' +
        OOB_TIME_FORMATS.inspect
    end

    @out_of_bounds_time_format = format
  end

  private

  def estimated
    memo_estimated_seconds_remaining = estimated_seconds_remaining

    return OOB_UNKNOWN_TIME_TEXT unless memo_estimated_seconds_remaining

    hours, minutes, seconds = timer.divide_seconds(memo_estimated_seconds_remaining)

    if hours > OOB_LIMIT_IN_HOURS && out_of_bounds_time_format
      out_of_bounds_time
    else
      TIME_FORMAT % [hours, minutes, seconds]
    end
  end

  def elapsed
    return NO_TIME_ELAPSED_TEXT unless timer.started?

    hours, minutes, seconds = timer.divide_seconds(timer.elapsed_whole_seconds)

    TIME_FORMAT % [hours, minutes, seconds]
  end

  def estimated_with_elapsed_fallback
    progress.finished? ? elapsed_with_label : estimated_with_label
  end

  def estimated_seconds_remaining
    return if progress.unknown? || progress.none? || timer.stopped?

    (timer.elapsed_seconds * (progress.total / progress.running_average - 1)).round
  end

  def out_of_bounds_time
    case out_of_bounds_time_format
    when :unknown
      OOB_UNKNOWN_TIME_TEXT
    when :friendly
      OOB_FRIENDLY_TIME_TEXT
    end
  end
end
end
end
