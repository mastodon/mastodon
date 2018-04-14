require 'rubygems'
require 'test-unit'
require 'uri'
require 'http/cookie'

module Test
  module Unit
    module Assertions
      def assert_warn(pattern, message = nil, &block)
        class << (output = "")
          alias write <<
        end
        stderr, $stderr = $stderr, output
        yield
        assert_match(pattern, output, message)
      ensure
        $stderr = stderr
      end

      def assert_warning(pattern, message = nil, &block)
        verbose, $VERBOSE = $VERBOSE, true
        assert_warn(pattern, message, &block)
      ensure
        $VERBOSE = verbose
      end
    end
  end
end

module Enumerable
  def combine
    masks = inject([[], 1]){|(ar, m), e| [ar << m, m << 1 ] }[0]
    all = masks.inject(0){ |al, m| al|m }

    result = []
    for i in 1..all do
      tmp = []
      each_with_index do |e, idx|
        tmp << e unless (masks[idx] & i) == 0
      end
      result << tmp
    end
    result
  end
end

def test_file(filename)
  File.expand_path(filename, File.dirname(__FILE__))
end

def sleep_until(time)
  if (s = time - Time.now) > 0
    sleep s
  end
end
