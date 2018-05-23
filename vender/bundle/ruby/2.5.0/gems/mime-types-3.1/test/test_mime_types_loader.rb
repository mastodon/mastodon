# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Types::Loader do
  def setup
    @path     = File.expand_path('../fixture', __FILE__)
    @loader   = MIME::Types::Loader.new(@path)
    @bad_path = File.expand_path('../bad-fixtures', __FILE__)
  end

  def assert_correctly_loaded(types)
    assert_includes(types, 'application/1d-interleaved-parityfec')
    assert_equal(%w(webm), types['audio/webm'].first.extensions)
    refute(types['audio/webm'].first.registered?)

    assert_equal('Fixes a bug with IE6 and progressive JPEGs',
                 types['image/pjpeg'].first.docs)

    assert(types['audio/vnd.qcelp'].first.obsolete?)
    assert_equal('audio/QCELP', types['audio/vnd.qcelp'].first.use_instead)
  end

  it 'loads YAML files correctly' do
    assert_correctly_loaded @loader.load_yaml
  end

  it 'loads JSON files correctly' do
    assert_correctly_loaded @loader.load_json
  end
end
