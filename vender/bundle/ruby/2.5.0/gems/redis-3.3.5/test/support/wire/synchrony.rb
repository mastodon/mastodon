class Wire < Fiber
  # We cannot run this fiber explicitly because EM schedules it. Resuming the
  # current fiber on the next tick to let the reactor do work.
  def self.pass
    f = Fiber.current
    EM.next_tick { f.resume }
    Fiber.yield
  end

  def self.sleep(sec)
    EM::Synchrony.sleep(sec)
  end

  def initialize(&blk)
    super

    # Schedule run in next tick
    EM.next_tick { resume }
  end

  def join
    self.class.pass while alive?
  end
end
