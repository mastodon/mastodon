module Fog
  @interval = lambda { |retries| [2**(retries - 1), @max_interval].min }

  class << self
    attr_reader :interval
  end

  def self.interval=(interval)
    if interval.is_a?(Proc)
      raise ArgumentError, "interval proc must return a positive" unless interval.call(1) >= 0
    else
      raise ArgumentError, "interval must be non-negative" unless interval >= 0
    end
    @interval = interval
  end

  @timeout = 600

  class << self
    attr_reader :timeout
  end

  def self.timeout=(timeout)
    raise ArgumentError, "timeout must be non-negative" unless timeout >= 0
    @timeout = timeout
  end

  @max_interval = 60

  class << self
    attr_reader :max_interval
  end

  def self.max_interval=(interval)
    raise ArgumentError, "interval must be non-negative" unless interval >= 0
    @max_interval = interval
  end
end
