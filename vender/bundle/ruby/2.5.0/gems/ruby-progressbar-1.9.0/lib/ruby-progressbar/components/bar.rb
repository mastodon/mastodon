###
# UPA = Unknown Progress Animation
#
class   ProgressBar
module  Components
class   Bar
  DEFAULT_PROGRESS_MARK  = '='.freeze
  DEFAULT_REMAINDER_MARK = ' '.freeze
  DEFAULT_UPA_STEPS      = ['=---', '-=--', '--=-', '---='].freeze

  attr_accessor :progress_mark,
                :remainder_mark,
                :length,
                :progress,
                :upa_steps

  def initialize(options = {})
    self.upa_steps      = options[:unknown_progress_animation_steps] || DEFAULT_UPA_STEPS
    self.progress_mark  = options[:progress_mark]  || DEFAULT_PROGRESS_MARK
    self.remainder_mark = options[:remainder_mark] || DEFAULT_REMAINDER_MARK
    self.progress       = options[:progress]
    self.length         = options[:length]
  end

  def to_s(options = { :format => :standard })
    if progress.unknown?
      unknown_string
    elsif options[:format] == :standard
      "#{standard_complete_string}#{incomplete_string}"
    elsif options[:format] == :integrated_percentage
      "#{integrated_percentage_complete_string}#{incomplete_string}"
    end
  end

  private

  def integrated_percentage_complete_string
    return standard_complete_string if completed_length < 5

    " #{progress.percentage_completed} ".to_s.center(completed_length, progress_mark)
  end

  def standard_complete_string
    progress_mark * completed_length
  end

  def incomplete_string
    remainder_mark * (length - completed_length)
  end

  def bar(length)
    self.length = length

    standard_complete_string
  end

  def complete_bar(length)
    self.length = length

    to_s
  end

  def unknown_string
    unknown_frame_string = unknown_progress_frame * ((length / upa_steps.size) + 2)

    unknown_frame_string[0, length]
  end

  def incomplete_space(length)
    self.length = length

    if progress.unknown?
      unknown_string
    else
      incomplete_string
    end
  end

  def bar_with_percentage(length)
    self.length = length

    integrated_percentage_complete_string
  end

  def completed_length
    (length * progress.percentage_completed / 100).floor
  end

  def unknown_progress_frame
    current_animation_step = progress.progress % upa_steps.size

    upa_steps[current_animation_step]
  end
end
end
end
