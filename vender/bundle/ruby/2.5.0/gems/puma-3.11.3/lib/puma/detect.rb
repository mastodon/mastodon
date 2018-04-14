module Puma
  IS_JRUBY = defined?(JRUBY_VERSION)

  def self.jruby?
    IS_JRUBY
  end

  IS_WINDOWS = RUBY_PLATFORM =~ /mswin|ming|cygwin/

  def self.windows?
    IS_WINDOWS
  end
end
