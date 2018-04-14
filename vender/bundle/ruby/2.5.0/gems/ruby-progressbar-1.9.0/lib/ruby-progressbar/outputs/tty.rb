require 'ruby-progressbar/output'

class   ProgressBar
module  Outputs
class   Tty < Output
  DEFAULT_FORMAT_STRING = '%t: |%B|'.freeze

  alias refresh_with_format_change with_refresh

  def clear
    stream.print clear_string
    stream.print "\r"
  end

  def bar_update_string
    bar.to_s
  end

  def default_format
    DEFAULT_FORMAT_STRING
  end

  def resolve_format(other_format)
    other_format || default_format
  end

  def eol
    bar.stopped? ? "\n" : "\r"
  end
end
end
end
