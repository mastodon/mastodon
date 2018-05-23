class FakeLogger
  def initialize(options = {})
    @tty = options[:tty]
    @entries = []
  end

  def info(text)
    @entries << text
  end

  def entries
    @entries
  end

  def tty?
    @tty
  end
end
