require "support/wire/synchrony"

module Helper
  def around
    rv = nil

    EM.synchrony do
      begin
        rv = yield
      ensure
        EM.stop
      end
    end

    rv
  end
end
