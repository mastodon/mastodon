# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Types, 'lazy loading' do
  def setup
    ENV['RUBY_MIME_TYPES_LAZY_LOAD'] = 'true'
  end

  def teardown
    reset_mime_types
    ENV.delete('RUBY_MIME_TYPES_LAZY_LOAD')
  end

  def reset_mime_types
    MIME::Types.instance_variable_set(:@__types__, nil)
    MIME::Types.send(:load_default_mime_types)
  end

  describe '.lazy_load?' do
    it 'is true when RUBY_MIME_TYPES_LAZY_LOAD is set' do
      assert_equal true, MIME::Types.send(:lazy_load?)
    end

    it 'is nil when RUBY_MIME_TYPES_LAZY_LOAD is unset' do
      ENV['RUBY_MIME_TYPES_LAZY_LOAD'] = nil
      assert_equal nil, MIME::Types.send(:lazy_load?)
    end

    it 'is false when RUBY_MIME_TYPES_LAZY_LOAD is false' do
      ENV['RUBY_MIME_TYPES_LAZY_LOAD'] = 'false'
      assert_equal false, MIME::Types.send(:lazy_load?)
    end
  end

  it 'loads lazily when RUBY_MIME_TYPES_LAZY_LOAD is set' do
    MIME::Types.instance_variable_set(:@__types__, nil)
    assert_nil MIME::Types.instance_variable_get(:@__types__)
    refute_nil MIME::Types['text/html'].first
    refute_nil MIME::Types.instance_variable_get(:@__types__)
  end
end
