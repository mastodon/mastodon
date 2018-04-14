require File.join(File.expand_path(File.dirname(__FILE__)), 'test_utils')
require 'rational' unless defined?(Rational)

include TZInfo

class TCTimeOrDateTime < Minitest::Test
  def test_initialize_time
    assert_nothing_raised do
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000))
    end
  end
  
  def test_initialize_time_local 
    tdt = TimeOrDateTime.new(Time.local(2006, 3, 24, 15, 32, 3))
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), tdt.to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), tdt.to_orig)
    assert(tdt.to_time.utc?)
    assert(tdt.to_orig.utc?)
  end
  
  def test_intialize_time_local_usec
    tdt = TimeOrDateTime.new(Time.local(2006, 3, 24, 15, 32, 3, 721123))
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123), tdt.to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123), tdt.to_orig)
    assert(tdt.to_time.utc?)
    assert(tdt.to_orig.utc?)
  end
  
  if Time.utc(2013, 1, 1).respond_to?(:nsec)
    def test_initialize_time_local_nsec
      tdt = TimeOrDateTime.new(Time.local(2006, 3, 24, 15, 32, 3, 721123 + Rational(456,1000)))
      assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123 + Rational(456,1000)), tdt.to_time)
      assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123 + Rational(456,1000)), tdt.to_orig)
      assert(tdt.to_time.utc?)
      assert(tdt.to_orig.utc?)
    end
  end
  
  def test_initialize_time_utc_local
    # Check that local Time instances on systems using UTC as the system 
    # time zone are still converted to UTC Time instances.
    
    # Note that this will only test will only work correctly on platforms where
    # setting the TZ environment variable has an effect. If setting TZ has no
    # effect, then this test will still pass.
    
    old_tz = ENV['TZ']
    begin
      ENV['TZ'] = 'UTC'
      tdt = TimeOrDateTime.new(Time.local(2014, 1, 11, 17, 18, 41))
      assert_equal(Time.utc(2014, 1, 11, 17, 18, 41), tdt.to_time)
      assert_equal(Time.utc(2014, 1, 11, 17, 18, 41), tdt.to_orig)
      assert(tdt.to_time.utc?)
      assert(tdt.to_orig.utc?)
    ensure
      ENV['TZ'] = old_tz
    end
  end
  
  def test_initialize_datetime_offset
    tdt = TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3).new_offset(Rational(5, 24)))
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), tdt.to_datetime)
    assert_equal(0, tdt.to_datetime.offset)
  end
  
  def test_initialize_datetime
    assert_nothing_raised do
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3))
    end
  end
  
  def test_initialize_timestamp
    assert_nothing_raised do
      TimeOrDateTime.new(1143214323)
    end
  end
  
  def test_initialize_timestamp_string
    assert_nothing_raised do
      TimeOrDateTime.new('1143214323')
    end
  end
  
  unless RubyCoreSupport.time_supports_64bit
    # Only define this test for non-64bit platforms. Some 64-bit Rubies support
    # greater than 64-bit, others support less than the full range. In either
    # case, times at the far ends of the range are so far in the future or past
    # that they are not going to turn up in timezone data.  
    def test_initialize_timestamp_supported_range      
      assert_equal((2 ** 31) - 1, TimeOrDateTime.new((2 ** 31) - 1).to_orig)
    
      assert_raises(RangeError) do
        TimeOrDateTime.new(2 ** 31)
      end
    
      if RubyCoreSupport.time_supports_negative
        assert_equal(-(2 ** 31), TimeOrDateTime.new(-(2 ** 31)).to_orig)
      
        assert_raises(RangeError) do
          TimeOrDateTime.new(-(2 ** 31) - 1)
        end
      else
        assert_equal(0, TimeOrDateTime.new(0).to_orig)
      
        assert_raises(RangeError) do
          TimeOrDateTime.new(-1)
        end
      end
    end
  end
  
  def test_to_time
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721123)).to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123, 1000000))).to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(1143214323).to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new('1143214323').to_time)
  end
  
  def test_to_time_trunc_to_usec
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721123),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(7211239, 10000000))).to_time)
  end

  def test_to_time_after_freeze
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).freeze.to_time)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(1143214323).freeze.to_time)
  end
  
  def test_to_datetime
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123, 1000000)),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721123)).to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123, 1000000)),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123, 1000000))).to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(1143214323).to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new('1143214323').to_datetime)
  end
  
  def test_to_datetime_ruby186_bug
    # DateTime.new in Ruby 1.8.6 won't allow a time to be specified using 
    # fractions of a second that is within the 60th second of a minute.
    
    # TimeOrDateTime has a workaround for this issue.
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 59) + Rational(721123, 86400000000),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 59, 721123)).to_datetime)
  end
  
  def test_to_datetime_trunc_to_usec
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123, 1000000)),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721123 + Rational(9, 10))).to_datetime)
  end

  def test_to_datetime_after_freeze
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).freeze.to_datetime)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(1143214323).freeze.to_datetime)
  end
  
  def test_to_i
    assert_equal(1143214323,
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).to_i)
    assert_equal(1143214323,
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).to_i)
    assert_equal(1143214323,
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).to_i)
    assert_equal(1143214323,
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).to_i)
    assert_equal(1143214323,
      TimeOrDateTime.new(1143214323).to_i)
    assert_equal(1143214323,
      TimeOrDateTime.new('1143214323').to_i)
  end

  def test_to_i_after_freeze
    assert_equal(1143214323, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).freeze.to_i)
    assert_equal(1143214323, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).freeze.to_i)
  end
  
  def test_to_orig
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721000),
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)),
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).to_orig)
    assert_equal(1143214323,
      TimeOrDateTime.new(1143214323).to_orig)
    assert_equal(1143214323,
      TimeOrDateTime.new('1143214323').to_orig) 
  end
  
  def test_to_s
    assert_equal("Time: #{Time.utc(2006, 3, 24, 15, 32, 3).to_s}",
      TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).to_s)
    assert_equal("DateTime: #{DateTime.new(2006, 3, 24, 15, 32, 3)}",
      TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).to_s)
    assert_equal('Timestamp: 1143214323',
      TimeOrDateTime.new(1143214323).to_s)
    assert_equal('Timestamp: 1143214323',
      TimeOrDateTime.new('1143214323').to_s) 
  end
  
  def test_year
    assert_equal(2006, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).year)
    assert_equal(2006, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).year)
    assert_equal(2006, TimeOrDateTime.new(1143214323).year)
  end
  
  def test_mon
    assert_equal(3, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).mon)
    assert_equal(3, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).mon)
    assert_equal(3, TimeOrDateTime.new(1143214323).mon)    
  end
  
  def test_month
    assert_equal(3, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).month)
    assert_equal(3, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).month)
    assert_equal(3, TimeOrDateTime.new(1143214323).month)
  end
  
  def test_mday
    assert_equal(24, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).mday)
    assert_equal(24, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).mday)
    assert_equal(24, TimeOrDateTime.new(1143214323).mday)
  end
  
  def test_day
    assert_equal(24, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).day)
    assert_equal(24, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).day)
    assert_equal(24, TimeOrDateTime.new(1143214323).day)
  end
  
  def test_hour
    assert_equal(15, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).hour)
    assert_equal(15, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).hour)
    assert_equal(15, TimeOrDateTime.new(1143214323).hour)
  end
  
  def test_min
    assert_equal(32, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).min)
    assert_equal(32, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).min)
    assert_equal(32, TimeOrDateTime.new(1143214323).min)
  end
  
  def test_sec
    assert_equal(3, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).sec)
    assert_equal(3, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).sec)
    assert_equal(3, TimeOrDateTime.new(1143214323).sec)
  end
  
  def test_usec
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).usec)
    assert_equal(721123, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721123)).usec)
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).usec)
    assert_equal(721123, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721123,1000000))).usec)
    assert_equal(0, TimeOrDateTime.new(1143214323).usec)
  end

  def test_usec_after_to_i
    val = TimeOrDateTime.new(Time.utc(2013, 2, 4, 22, 10, 33, 598000))
    assert_equal(Time.utc(2013, 2, 4, 22, 10, 33).to_i, val.to_i)
    assert_equal(598000, val.usec)
  end
    
  def test_compare_timeordatetime_time
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2007, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2005, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2007, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2005, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(Time.utc(2007, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(Time.utc(2005, 3, 24, 15, 32, 3)))
    
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500001)))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 499999)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000 + DATETIME_RESOLUTION)))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000 - DATETIME_RESOLUTION)))
  end
  
  def test_compare_timeordatetime_datetime
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 4)))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)))
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 2)))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)))
    
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 + DATETIME_RESOLUTION, 1000000))))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 - DATETIME_RESOLUTION, 1000000))))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 + DATETIME_RESOLUTION, 1000000))))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 - DATETIME_RESOLUTION, 1000000))))
  end
  
  def test_compare_timeordatetime_timestamp
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214324))
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1174750323))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214323))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214322))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1111678323))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214324))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1174750323))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214323))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214322))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1111678323))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214323))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> TimeOrDateTime.new(1143214323))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(1143214324))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(1174750323))
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(1143214323))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(1143214322))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> TimeOrDateTime.new(1111678323))
  end
  
  def test_compare_time
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2007, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2005, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2007, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Time.utc(2005, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> Time.utc(2006, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> Time.utc(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> Time.utc(2007, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> Time.utc(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> Time.utc(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> Time.utc(2005, 3, 24, 15, 32, 3))
    
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> Time.utc(2006, 3, 24, 15, 32, 3, 500001))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> Time.utc(2006, 3, 24, 15, 32, 3, 500000))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> Time.utc(2006, 3, 24, 15, 32, 3, 499999))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> Time.utc(2006, 3, 24, 15, 32, 3, 500000 + DATETIME_RESOLUTION))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> Time.utc(2006, 3, 24, 15, 32, 3, 500000))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> Time.utc(2006, 3, 24, 15, 32, 3, 500000 - DATETIME_RESOLUTION))
  end
  
  def test_compare_datetime
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2040, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(1960, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2040, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> DateTime.new(1960, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> DateTime.new(2006, 3, 24, 15, 32, 4))
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> DateTime.new(2040, 3, 24, 15, 32, 3))
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> DateTime.new(2006, 3, 24, 15, 32, 2))
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> DateTime.new(1960, 3, 24, 15, 32, 3))
    
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 + DATETIME_RESOLUTION, 1000000)))
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000)))
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 500000)) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 - DATETIME_RESOLUTION, 1000000)))
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 + DATETIME_RESOLUTION, 1000000)))
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000)))
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000, 1000000))) <=> DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(500000 - DATETIME_RESOLUTION, 1000000)))
  end
  
  def test_compare_timestamp
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> 1143214324)
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> 1174750323)
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> 1143214323)
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> 1143214322)
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> 1111678323)
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> 1143214324)
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> 1174750323)
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> 1143214323)
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> 1143214322)
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> 1111678323)
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> 1143214323)
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> 1143214323)
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> 1143214324)
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> 1174750323)
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> 1143214323)
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> 1143214322)
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> 1111678323)
  end
  
  def test_compare_timestamp_str
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> '1143214324')
    assert_equal(-1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> '1174750323')
    assert_equal(0, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> '1143214323')
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> '1143214322')
    assert_equal(1, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> '1111678323')
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> '1143214324')
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> '1174750323')
    assert_equal(0, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> '1143214323')
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> '1143214322')
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> '1111678323')
    assert_equal(-1, TimeOrDateTime.new(DateTime.new(1960, 3, 24, 15, 32, 3)) <=> '1143214323')
    assert_equal(1, TimeOrDateTime.new(DateTime.new(2040, 3, 24, 15, 32, 3)) <=> '1143214323')
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> '1143214324')
    assert_equal(-1, TimeOrDateTime.new(1143214323) <=> '1174750323')
    assert_equal(0, TimeOrDateTime.new(1143214323) <=> '1143214323')
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> '1143214322')
    assert_equal(1, TimeOrDateTime.new(1143214323) <=> '1111678323')
  end
  
  def test_compare_non_comparable
    assert_nil(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) <=> Object.new)
    assert_nil(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) <=> Object.new)
    assert_nil(TimeOrDateTime.new(1143214323) <=> Object.new)
  end
  
  def test_eql
    assert_equal(true, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(1143214323)))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new('1143214323')))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 4))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).eql?(Object.new))
    
    assert_equal(true, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 722000))))
    assert_equal(false, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).eql?(Object.new))
    
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3))))
    assert_equal(true, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3))))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(1143214323)))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new('1143214323')))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 4))))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).eql?(Object.new))
    
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000))))
    assert_equal(true, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)))))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(722, 1000)))))
    assert_equal(false, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).eql?(Object.new))

    
    assert_equal(false, TimeOrDateTime.new(1143214323).eql?(TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3))))
    assert_equal(false, TimeOrDateTime.new(1143214323).eql?(TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3))))
    assert_equal(true, TimeOrDateTime.new(1143214323).eql?(TimeOrDateTime.new(1143214323)))
    assert_equal(true, TimeOrDateTime.new(1143214323).eql?(TimeOrDateTime.new('1143214323')))
    assert_equal(false, TimeOrDateTime.new(1143214323).eql?(TimeOrDateTime.new(1143214324)))
    assert_equal(false, TimeOrDateTime.new(1143214323).eql?(Object.new))
  end
  
  def test_hash
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3).hash, TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).hash)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3).hash, TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).hash)
    assert_equal(1143214323.hash, TimeOrDateTime.new(1143214323).hash)
    assert_equal(1143214323.hash, TimeOrDateTime.new('1143214323').hash)
  end
  
  def test_add
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) + 0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) + 0).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) + 0).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) + 0).to_orig)
    assert_equal(1143214323, (TimeOrDateTime.new(1143214323) + 0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) + 1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) + 1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) + 1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) + 1).to_orig)
    assert_equal(1143214324, (TimeOrDateTime.new(1143214323) + 1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) + (-1)).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) + (-1)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) + (-1)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) + (-1)).to_orig)
    assert_equal(1143214322, (TimeOrDateTime.new(1143214323) + (-1)).to_orig)
  end
  
  def test_subtract     
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) - 0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) - 0).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) - 0).to_orig)   
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) - 0).to_orig)   
    assert_equal(1143214323, (TimeOrDateTime.new(1143214323) - 0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) - 1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) - 1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) - 1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) - 1).to_orig)
    assert_equal(1143214322, (TimeOrDateTime.new(1143214323) - 1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)) - (-1)).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4, 721000), (TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)) - (-1)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)) - (-1)).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4 + Rational(721, 1000)), (TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))) - (-1)).to_orig)
    assert_equal(1143214324, (TimeOrDateTime.new(1143214323) - (-1)).to_orig)
  end
  
  def test_add_with_convert
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).add_with_convert(0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3, 721000), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).add_with_convert(0).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).add_with_convert(0).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000)), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).add_with_convert(0).to_orig)
    assert_equal(1143214323, TimeOrDateTime.new(1143214323).add_with_convert(0).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).add_with_convert(1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4, 721000), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).add_with_convert(1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).add_with_convert(1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4 + Rational(721, 1000)), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).add_with_convert(1).to_orig)
    assert_equal(1143214324, TimeOrDateTime.new(1143214323).add_with_convert(1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3)).add_with_convert(-1).to_orig)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 2, 721000), TimeOrDateTime.new(Time.utc(2006, 3, 24, 15, 32, 3, 721000)).add_with_convert(-1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3)).add_with_convert(-1).to_orig)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 2 + Rational(721, 1000)), TimeOrDateTime.new(DateTime.new(2006, 3, 24, 15, 32, 3 + Rational(721, 1000))).add_with_convert(-1).to_orig)
    assert_equal(1143214322, TimeOrDateTime.new(1143214323).add_with_convert(-1).to_orig)
    
    if RubyCoreSupport.time_supports_negative
      assert_equal(Time.utc(1969, 12, 31, 23, 59, 59), TimeOrDateTime.new(Time.utc(1970, 1, 1, 0, 0, 0)).add_with_convert(-1).to_orig)
      assert_equal(-1, TimeOrDateTime.new(0).add_with_convert(-1).to_orig)
      assert_equal(Time.utc(1969, 12, 31, 23, 59, 59, 892000), TimeOrDateTime.new(Time.utc(1970, 1, 1, 0, 0, 0, 892000)).add_with_convert(-1).to_orig)
      
      if RubyCoreSupport.time_supports_64bit
        assert_equal(Time.utc(1901, 12, 13, 20, 45, 51), TimeOrDateTime.new(Time.utc(1901, 12, 13, 20, 45, 52)).add_with_convert(-1).to_orig)
        assert_equal(-2147483649, TimeOrDateTime.new(-2147483648).add_with_convert(-1).to_orig)
        assert_equal(Time.utc(1901, 12, 13, 20, 45, 51, 892000), TimeOrDateTime.new(Time.utc(1901, 12, 13, 20, 45, 52, 892000)).add_with_convert(-1).to_orig)
      else
        assert_equal(DateTime.new(1901, 12, 13, 20, 45, 51), TimeOrDateTime.new(Time.utc(1901, 12, 13, 20, 45, 52)).add_with_convert(-1).to_orig)
        assert_equal(DateTime.new(1901, 12, 13, 20, 45, 51), TimeOrDateTime.new(-2147483648).add_with_convert(-1).to_orig)
        assert_equal(DateTime.new(1901, 12, 13, 20, 45, 51 + Rational(892,1000)), TimeOrDateTime.new(Time.utc(1901, 12, 13, 20, 45, 52, 892000)).add_with_convert(-1).to_orig)
      end
    else
      assert_equal(DateTime.new(1969, 12, 31, 23, 59, 59), TimeOrDateTime.new(Time.utc(1970, 1, 1, 0, 0, 0)).add_with_convert(-1).to_orig)
      assert_equal(DateTime.new(1969, 12, 31, 23, 59, 59), TimeOrDateTime.new(0).add_with_convert(-1).to_orig)
      assert_equal(RubyCoreSupport.datetime_new(1969, 12, 31, 23, 59, 59 + Rational(892,1000)), TimeOrDateTime.new(Time.utc(1970, 1, 1, 0, 0, 0, 892000)).add_with_convert(-1).to_orig)
    end
    
    if RubyCoreSupport.time_supports_64bit      
      assert_equal(Time.utc(2038, 1, 19, 3, 14, 8), TimeOrDateTime.new(Time.utc(2038, 1, 19, 3, 14, 7)).add_with_convert(1).to_orig)
      assert_equal(2147483648, TimeOrDateTime.new(2147483647).add_with_convert(1).to_orig)
      assert_equal(Time.utc(2038, 1, 19, 3, 14, 8, 892000), TimeOrDateTime.new(Time.utc(2038, 1, 19, 3, 14, 7, 892000)).add_with_convert(1).to_orig)
    else      
      assert_equal(DateTime.new(2038, 1, 19, 3, 14, 8), TimeOrDateTime.new(Time.utc(2038, 1, 19, 3, 14, 7)).add_with_convert(1).to_orig)
      assert_equal(DateTime.new(2038, 1, 19, 3, 14, 8), TimeOrDateTime.new(2147483647).add_with_convert(1).to_orig)
      assert_equal(DateTime.new(2038, 1, 19, 3, 14, 8 + Rational(892,1000)), TimeOrDateTime.new(Time.utc(2038, 1, 19, 3, 14, 7, 892000)).add_with_convert(1).to_orig)
      
      assert_equal(Time.utc(2038, 1, 19, 3, 14, 7, 892000), TimeOrDateTime.new(Time.utc(2038, 1, 19, 3, 14, 6, 892000)).add_with_convert(1).to_orig)
    end    
  end
  
  def test_wrap_time
    t = TimeOrDateTime.wrap(Time.utc(2006, 3, 24, 15, 32, 3))
    assert_instance_of(TimeOrDateTime, t)
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), t.to_orig)
  end
  
  def test_wrap_datetime
    t = TimeOrDateTime.wrap(DateTime.new(2006, 3, 24, 15, 32, 3))
    assert_instance_of(TimeOrDateTime, t)
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), t.to_orig)
  end
  
  def test_wrap_timestamp
    t = TimeOrDateTime.wrap(1143214323)
    assert_instance_of(TimeOrDateTime, t)
    assert_equal(1143214323, t.to_orig)
  end 
  
  def test_wrap_timestamp_str
    t = TimeOrDateTime.wrap('1143214323')
    assert_instance_of(TimeOrDateTime, t)
    assert_equal(1143214323, t.to_orig)
  end

  def test_wrap_timeordatetime
    t = TimeOrDateTime.new(1143214323)
    t2 = TimeOrDateTime.wrap(t)
    assert_same(t, t2)    
  end
  
  def test_wrap_block_time
    assert_equal(Time.utc(2006, 3, 24, 15, 32, 4), TimeOrDateTime.wrap(Time.utc(2006, 3, 24, 15, 32, 3)) {|t|
      assert_instance_of(TimeOrDateTime, t)
      assert_equal(Time.utc(2006, 3, 24, 15, 32, 3), t.to_orig)
      t + 1
    })
  end
  
  def test_wrap_block_datetime
    assert_equal(DateTime.new(2006, 3, 24, 15, 32, 4), TimeOrDateTime.wrap(DateTime.new(2006, 3, 24, 15, 32, 3)) {|t|
      assert_instance_of(TimeOrDateTime, t)
      assert_equal(DateTime.new(2006, 3, 24, 15, 32, 3), t.to_orig)
      t + 1
    })
  end
  
  def test_wrap_block_timestamp
    assert_equal(1143214324, TimeOrDateTime.wrap(1143214323) {|t|
      assert_instance_of(TimeOrDateTime, t)
      assert_equal(1143214323, t.to_orig)
      t + 1
    })
  end
  
  def test_wrap_block_timestamp_str
    assert_equal(1143214324, TimeOrDateTime.wrap('1143214323') {|t|
      assert_instance_of(TimeOrDateTime, t)
      assert_equal(1143214323, t.to_orig)
      t + 1
    })
  end
  
  def test_wrap_block_timeordatetime
    t1 = TimeOrDateTime.new(1143214323)
        
    t2 = TimeOrDateTime.wrap(t1) {|t|
      assert_same(t1, t)
      t + 1           
    }
      
    assert t2
    assert_instance_of(TimeOrDateTime, t2)
    assert_equal(1143214324, t2.to_orig)
  end
end
