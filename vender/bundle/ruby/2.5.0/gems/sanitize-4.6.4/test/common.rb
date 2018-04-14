# encoding: utf-8
gem 'minitest'
require 'minitest/autorun'

require_relative '../lib/sanitize'

# Helper to stub an instance method. Shamelessly stolen from
# https://github.com/codeodor/minitest-stub_any_instance/
class Object
  def self.stub_instance(name, value, &block)
    old_method = "__stubbed_method_#{name}__"

    class_eval do
      alias_method old_method, name

      define_method(name) do |*args|
        if value.respond_to?(:call) then
          value.call(*args)
        else
          value
        end
      end
    end

    yield

  ensure
    class_eval do
      undef_method name
      alias_method name, old_method
      undef_method old_method
    end
  end
end
