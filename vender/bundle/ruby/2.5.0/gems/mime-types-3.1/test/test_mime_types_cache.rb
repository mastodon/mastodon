# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Types::Cache do
  include Minitest::Hooks

  MUTEX = Mutex.new

  def around
    require 'fileutils'

    MUTEX.synchronize do
      @cache_file = File.expand_path('../cache.tst', __FILE__)
      ENV['RUBY_MIME_TYPES_CACHE'] = @cache_file
      clear_cache_file

      super

      clear_cache_file
      ENV.delete('RUBY_MIME_TYPES_CACHE')
    end
  end

  def reset_mime_types
    MIME::Types.instance_variable_set(:@__types__, nil)
    MIME::Types.send(:load_default_mime_types)
  end

  def clear_cache_file
    FileUtils.rm @cache_file if File.exist? @cache_file
  end

  describe '.load' do
    it 'does not use cache when RUBY_MIME_TYPES_CACHE is unset' do
      ENV.delete('RUBY_MIME_TYPES_CACHE')
      assert_equal(nil, MIME::Types::Cache.load)
    end

    it 'does not use cache when missing' do
      assert_equal(nil, MIME::Types::Cache.load)
    end

    it 'outputs an error when there is an invalid version' do
      v = MIME::Types::Data::VERSION
      MIME::Types::Data.send(:remove_const, :VERSION)
      MIME::Types::Data.const_set(:VERSION, '0.0')
      MIME::Types::Cache.save
      MIME::Types::Data.send(:remove_const, :VERSION)
      MIME::Types::Data.const_set(:VERSION, v)
      MIME::Types.instance_variable_set(:@__types__, nil)
      assert_output '', /MIME::Types cache: invalid version/ do
        MIME::Types['text/html']
      end
    end

    it 'outputs an error when there is a marshal file incompatibility' do
      MIME::Types::Cache.save
      data = File.binread(@cache_file).reverse
      File.open(@cache_file, 'wb') { |f| f.write(data) }
      MIME::Types.instance_variable_set(:@__types__, nil)
      assert_output '', /incompatible marshal file format/ do
        MIME::Types['text/html']
      end
    end
  end

  describe '.save' do
    it 'does not create cache when RUBY_MIME_TYPES_CACHE is unset' do
      ENV.delete('RUBY_MIME_TYPES_CACHE')
      assert_equal(nil, MIME::Types::Cache.save)
    end

    it 'creates the cache ' do
      assert_equal(false, File.exist?(@cache_file))
      MIME::Types::Cache.save
      assert_equal(true, File.exist?(@cache_file))
    end

    it 'uses the cache' do
      MIME::Types['text/html'].first.add_extensions('hex')
      MIME::Types::Cache.save
      MIME::Types.instance_variable_set(:@__types__, nil)

      assert_includes MIME::Types['text/html'].first.extensions, 'hex'

      reset_mime_types
    end
  end
end

describe MIME::Types::Container do
  it 'marshals and unmarshals correctly' do
    container = MIME::Types::Container.new
    container['xyz'] << 'abc'

    # default proc should return Set[]
    assert_equal(Set[], container['abc'])
    assert_equal(Set['abc'], container['xyz'])

    marshalled = Marshal.dump(container)
    loaded_container = Marshal.load(marshalled)

    # default proc should still return Set[]
    assert_equal(Set[], loaded_container['abc'])
    assert_equal(Set['abc'], container['xyz'])
  end
end
