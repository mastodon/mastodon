require "forwardable"
require "thread"

module Hamster
  # @private
  module ReadCopyUpdate
    extend Forwardable

    def initialize(content)
      @content = content
      @lock = Mutex.new
    end

    def eql?(other)
      instance_of?(other.class) && @content.eql?(other.instance_variable_get(:@content))
    end
    alias :== :eql?

    def_delegator :@content, :inspect
    def_delegator :@content, :to_s

    protected

    def transform
      @lock.synchronize do
        @content = yield(@content)
      end
      self
    end

    private

    def method_missing(name, *args, &block)
      @content.send(name, *args, &block) rescue super
    end
  end
end
