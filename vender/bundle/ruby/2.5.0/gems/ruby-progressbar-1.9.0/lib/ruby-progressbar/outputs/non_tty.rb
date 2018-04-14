require 'ruby-progressbar/output'

class   ProgressBar
module  Outputs
class   NonTty < Output
  DEFAULT_FORMAT_STRING = '%t: |%b|'.freeze

  def clear
    self.last_update_length = 0

    stream.print "\n"
  end

  def last_update_length
    @last_update_length ||= 0
  end

  def bar_update_string
    formatted_string        = bar.to_s
    formatted_string        = formatted_string[0...-1] unless bar.finished?

    output_string           = formatted_string[last_update_length..-1]
    self.last_update_length = formatted_string.length

    output_string
  end

  def default_format
    DEFAULT_FORMAT_STRING
  end

  def resolve_format(*)
    default_format
  end

  def refresh_with_format_change(*); end

  def eol
    bar.stopped? ? "\n" : ''
  end

  protected

  attr_writer :last_update_length
end
end
end
