#!/usr/bin/env ruby
# encoding: UTF-8
#frozen_string_literal: false

require 'json_gem/test_helper'

require 'time'

class JSONStringMatchingTest < Test::Unit::TestCase
  include Test::Unit::TestCaseOmissionSupport

  class TestTime < ::Time
    def self.json_create(string)
      Time.parse(string)
    end

    def to_json(*)
      %{"#{strftime('%FT%T%z')}"}
    end

    def ==(other)
      to_i == other.to_i
    end
  end

  def test_match_date
    t = TestTime.new
    t_json = [ t ].to_json
    time_regexp = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4}\z/
    assert_equal [ t ],
      JSON.parse(
        t_json,
        :create_additions => true,
        :match_string => { time_regexp => TestTime }
      )
    assert_equal [ t.strftime('%FT%T%z') ],
      JSON.parse(
        t_json,
        :match_string => { time_regexp => TestTime }
      )
  end
end
