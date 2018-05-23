class   ProgressBar
class   Output
  DEFAULT_OUTPUT_STREAM = $stdout

  attr_accessor :stream

  def initialize(options = {})
    self.bar               = options[:bar]
    self.stream            = options[:output] || DEFAULT_OUTPUT_STREAM
    self.throttle          = Throttle.new(options)
    self.length_calculator = Calculators::Length.new(
                               :length => options[:length],
                               :output => stream
                             )
  end

  def self.detect(options = {})
    if options[:output].is_a?(Class) && options[:output] <= ProgressBar::Output
      options[:output].new(options)
    elsif (options[:output] || DEFAULT_OUTPUT_STREAM).tty?
      Outputs::Tty.new(options)
    else
      Outputs::NonTty.new(options)
    end
  end

  def log(string)
    clear
    stream.puts string

    refresh(:force => true) unless bar.stopped?
  end

  def clear_string
    ' ' * length_calculator.length
  end

  def length
    length_calculator.length
  end

  def with_refresh
    yield
    refresh
  end

  def refresh(options = {})
    throttle.choke(:force_update_if => (bar.stopped? || options[:force])) do
      clear if length_calculator.length_changed?

      print_and_flush
    end
  end

  protected

  attr_accessor :length_calculator,
                :throttle,
                :bar

  private

  def print_and_flush
    stream.print bar_update_string + eol
    stream.flush
  end
end
end
