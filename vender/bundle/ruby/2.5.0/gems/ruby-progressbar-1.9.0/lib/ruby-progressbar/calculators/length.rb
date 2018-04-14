class   ProgressBar
module  Calculators
class   Length
  attr_reader   :length_override
  attr_accessor :current_length,
                :output

  def initialize(options = {})
    self.length_override = options[:length]
    self.output          = options[:output]
    self.current_length  = nil
  end

  def length
    current_length || reset_length
  end

  def length_changed?
    previous_length     = current_length
    self.current_length = calculate_length

    previous_length != current_length
  end

  def calculate_length
    length_override || terminal_width || 80
  end

  def reset_length
    self.current_length = calculate_length
  end

  def length_override=(other)
    @length_override ||= ENV['RUBY_PROGRESS_BAR_LENGTH'] || other
    @length_override = @length_override.to_i if @length_override
  end

  private

  # This code was copied and modified from Rake, available under MIT-LICENSE
  # Copyright (c) 2003, 2004 Jim Weirich
  # rubocop:disable Lint/RescueWithoutErrorClass
  def terminal_width
    return 80 unless unix?

    result = dynamic_width
    (result < 20) ? 80 : result
  rescue
    80
  end
  # rubocop:enable Lint/RescueWithoutErrorClass

  # rubocop:disable Lint/DuplicateMethods
  begin
    require 'io/console'

    def dynamic_width
      if output && output.tty?
        dynamic_width_via_output_stream_object
      elsif IO.console
        dynamic_width_via_io_object
      else
        dynamic_width_via_system_calls
      end
    end
  rescue LoadError
    def dynamic_width
      dynamic_width_via_system_calls
    end
  end

  def dynamic_width_via_output_stream_object
    _rows, columns = output.winsize
    columns
  end

  def dynamic_width_via_io_object
    _rows, columns = IO.console.winsize
    columns
  end

  def dynamic_width_via_system_calls
    dynamic_width_stty.nonzero? || dynamic_width_tput
  end

  def dynamic_width_stty
    `stty size 2>/dev/null`.split[1].to_i
  end

  def dynamic_width_tput
    `tput cols 2>/dev/null`.to_i
  end

  def unix?
    RUBY_PLATFORM =~ /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i
  end
end
end
end
