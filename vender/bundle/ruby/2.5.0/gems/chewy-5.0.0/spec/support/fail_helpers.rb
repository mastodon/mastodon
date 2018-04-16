module FailHelpers
  def fail
    raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  def fail_with(message)
    raise_error(RSpec::Expectations::ExpectationNotMetError, message)
  end

  def fail_matching(message)
    raise_error(RSpec::Expectations::ExpectationNotMetError, /#{Regexp.escape(message)}/)
  end
end
