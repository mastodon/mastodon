# frozen_string_literal: true

def capture_warning
  old_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr.string
ensure
  $stderr = old_stderr
end
