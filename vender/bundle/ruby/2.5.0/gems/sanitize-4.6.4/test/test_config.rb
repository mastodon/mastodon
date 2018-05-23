# encoding: utf-8
require_relative 'common'

describe 'Config' do
  make_my_diffs_pretty!
  parallelize_me!

  def verify_deeply_frozen(config)
    config.must_be :frozen?

    if Hash === config
      config.each_value {|v| verify_deeply_frozen(v) }
    elsif Set === config || Array === config
      config.each {|v| verify_deeply_frozen(v) }
    end
  end

  it 'built-in configs should be deeply frozen' do
    verify_deeply_frozen Sanitize::Config::DEFAULT
    verify_deeply_frozen Sanitize::Config::BASIC
    verify_deeply_frozen Sanitize::Config::RELAXED
    verify_deeply_frozen Sanitize::Config::RESTRICTED
  end

  describe '.freeze_config' do
    it 'should deeply freeze and return a configuration Hash' do
      a = {:one => {:one_one => [0, '1', :a], :one_two => false, :one_three => Set.new([:a, :b, :c])}}
      b = Sanitize::Config.freeze_config(a)

      b.must_be_same_as a
      verify_deeply_frozen a
    end
  end

  describe '.merge' do
    it 'should deeply merge a configuration Hash' do
      # Freeze to ensure that we get an error if either Hash is modified.
      a = Sanitize::Config.freeze_config({:one => {:one_one => [0, '1', :a], :one_two => false, :one_three => Set.new([:a, :b, :c])}})
      b = Sanitize::Config.freeze_config({:one => {:one_two => true, :one_three => 3}, :two => 2})

      c = Sanitize::Config.merge(a, b)

      c.wont_be_same_as a
      c.wont_be_same_as b

      c.must_equal(
        :one => {
          :one_one   => [0, '1', :a],
          :one_two   => true,
          :one_three => 3
        },

        :two => 2
      )

      c[:one].wont_be_same_as a[:one]
      c[:one][:one_one].wont_be_same_as a[:one][:one_one]
    end

    it 'should raise an ArgumentError if either argument is not a Hash' do
      proc { Sanitize::Config.merge('foo', {}) }.must_raise ArgumentError
      proc { Sanitize::Config.merge({}, 'foo') }.must_raise ArgumentError
    end
  end
end
