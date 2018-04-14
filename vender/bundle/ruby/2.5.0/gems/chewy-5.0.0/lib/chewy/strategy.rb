require 'chewy/strategy/base'
require 'chewy/strategy/bypass'
require 'chewy/strategy/urgent'
require 'chewy/strategy/atomic'

begin
  require 'resque'
  require 'chewy/strategy/resque'
rescue LoadError
  nil
end

begin
  require 'sidekiq'
  require 'chewy/strategy/sidekiq'
rescue LoadError
  nil
end

begin
  require 'shoryuken'
  require 'chewy/strategy/shoryuken'
rescue LoadError
  nil
end

begin
  require 'active_job'
  require 'chewy/strategy/active_job'
rescue LoadError
  nil
end

module Chewy
  # This class represents strategies stack with `:base`
  # Strategy on top of it. This causes raising exceptions
  # on every index update attempt, so other strategy must
  # be choosen.
  #
  #   User.first.save # Raises UndefinedUpdateStrategy exception
  #
  #   Chewy.strategy(:atomic) do
  #     User.last.save # Save user according to the `:atomic` strategy rules
  #   end
  #
  class Strategy
    def initialize
      @stack = [resolve(Chewy.root_strategy).new]
    end

    def current
      @stack.last
    end

    def push(name)
      result = @stack.push resolve(name).new
      debug "[#{@stack.size - 1}] <- #{current.name}" if @stack.size > 2
      result
    end

    def pop
      raise "Can't pop root strategy" if @stack.one?
      result = @stack.pop.tap(&:leave)
      debug "[#{@stack.size}] -> #{result.name}, now #{current.name}" if @stack.size > 1
      result
    end

    def wrap(name)
      stack = push(name)
      yield
    ensure
      pop if stack
    end

  private

    def debug(string)
      return unless Chewy.logger && Chewy.logger.debug?
      line = caller.detect { |l| l !~ %r{lib/chewy/strategy.rb:|lib/chewy.rb:} }
      Chewy.logger.debug(["Chewy strategies stack: #{string}", line.sub(/:in\s.+$/, '')].join(' @ '))
    end

    def resolve(name)
      "Chewy::Strategy::#{name.to_s.camelize}".safe_constantize or raise "Can't find update strategy `#{name}`"
    rescue NameError => ex
      # WORKAROUND: Strange behavior of `safe_constantize` with mongoid gem
      raise "Can't find update strategy `#{name}`" if ex.name.to_s.demodulize == name.to_s.camelize
      raise
    end
  end
end
