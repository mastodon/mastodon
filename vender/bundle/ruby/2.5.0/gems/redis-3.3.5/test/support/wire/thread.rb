class Wire < Thread
  def self.sleep(sec)
    Kernel.sleep(sec)
  end
end
