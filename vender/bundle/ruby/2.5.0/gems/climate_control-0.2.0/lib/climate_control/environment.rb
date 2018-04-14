require "thread"
require "forwardable"

module ClimateControl
  class Environment
    extend Forwardable

    def initialize
      @semaphore = Mutex.new
      @owner = nil
    end

    def_delegators :env, :[]=, :to_hash, :[], :delete

    def synchronize
      if @owner == Thread.current
        return yield if block_given?
      end

      @semaphore.synchronize do
        begin
          @owner = Thread.current
          yield if block_given?
        ensure
          @owner = nil
        end
      end
    end

    private

    def env
      ENV
    end
  end
end
