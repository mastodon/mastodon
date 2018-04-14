module NSA

  def self.inform_statsd(backend)
    yield ::NSA::Statsd::Informant
    ::NSA::Statsd::Informant.listen(backend)
  end

end

require "nsa/version"
require "nsa/statsd"
