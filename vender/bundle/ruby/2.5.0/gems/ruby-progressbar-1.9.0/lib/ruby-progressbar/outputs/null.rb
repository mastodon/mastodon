require 'ruby-progressbar/output'

class   ProgressBar
module  Outputs
class   Null < Output
  alias refresh_with_format_change with_refresh

  def clear;        end
  def log(_string); end
  def refresh(*);   end

  def clear_string
    ''
  end

  def bar_update_string
    ''
  end

  def default_format
    ''
  end

  def resolve_format(_format)
    ''
  end

  def eol
    ''
  end
end
end
end
