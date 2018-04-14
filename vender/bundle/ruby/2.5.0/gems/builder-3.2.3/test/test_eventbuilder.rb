#!/usr/bin/env ruby

#--
# Portions copyright 2004 by Jim Weirich (jim@weirichhouse.org).
# Portions copyright 2005 by Sam Ruby (rubys@intertwingly.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

require 'helper'
require 'preload'
require 'builder'
require 'builder/xmlevents'

class TestEvents < Builder::Test

  class Target
    attr_reader :events

    def initialize
      @events = []
    end

    def start_tag(tag, attrs)
      @events << [:start_tag, tag, attrs]
    end

    def end_tag(tag)
      @events << [:end_tag, tag]
    end
    
    def text(string)
      @events << [:text, string]
    end
    
  end


  def setup
    @target = Target.new
    @xml = Builder::XmlEvents.new(:target=>@target)
  end

  def test_simple
    @xml.one
    expect [:start_tag, :one, nil]
    expect [:end_tag, :one]
    expect_done
  end

  def test_nested
    @xml.one { @xml.two }
    expect [:start_tag, :one, nil]
    expect [:start_tag, :two, nil]
    expect [:end_tag, :two]
    expect [:end_tag, :one]
    expect_done
  end

  def test_text
    @xml.one("a")
    expect [:start_tag, :one, nil]
    expect [:text, "a"]
    expect [:end_tag, :one]
    expect_done
  end

  def test_special_text
    @xml.one("H&R")
    expect [:start_tag, :one, nil]
    expect [:text, "H&R"]
    expect [:end_tag, :one]
    expect_done
  end

  def test_text_with_entity
    @xml.one("H&amp;R")
    expect [:start_tag, :one, nil]
    expect [:text, "H&amp;R"]
    expect [:end_tag, :one]
    expect_done
  end

  def test_attributes
    @xml.a(:b=>"c", :x=>"y")
    expect [:start_tag, :a, {:x => "y", :b => "c"}]
    expect [:end_tag, :a]
    expect_done
  end

  def test_moderately_complex
    @xml.tag! "address-book" do |x|
      x.entry :id=>"1" do
	x.name {
	  x.first "Bill"
	  x.last "Smith"
	}
	x.address "Cincinnati"
      end
      x.entry :id=>"2" do
	x.name {
	  x.first "John"
	  x.last "Doe"
	}
	x.address "Columbus"
      end
    end
    expect [:start_tag, "address-book".intern, nil]
    expect [:start_tag, :entry, {:id => "1"}]
    expect [:start_tag, :name, nil]
    expect [:start_tag, :first, nil]
    expect [:text, "Bill"]
    expect [:end_tag, :first]
    expect [:start_tag, :last, nil]
    expect [:text, "Smith"]
    expect [:end_tag, :last]
    expect [:end_tag, :name]
    expect [:start_tag, :address, nil]
    expect [:text, "Cincinnati"]
    expect [:end_tag, :address]
    expect [:end_tag, :entry]
    expect [:start_tag, :entry, {:id => "2"}]
    expect [:start_tag, :name, nil]
    expect [:start_tag, :first, nil]
    expect [:text, "John"]
    expect [:end_tag, :first]
    expect [:start_tag, :last, nil]
    expect [:text, "Doe"]
    expect [:end_tag, :last]
    expect [:end_tag, :name]
    expect [:start_tag, :address, nil]
    expect [:text, "Columbus"]
    expect [:end_tag, :address]
    expect [:end_tag, :entry]
    expect [:end_tag, "address-book".intern]
    expect_done
  end

  def expect(value)
    assert_equal value, @target.events.shift
  end

  def expect_done
    assert_nil @target.events.shift
  end

end
