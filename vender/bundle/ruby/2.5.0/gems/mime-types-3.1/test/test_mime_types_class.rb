# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Types, 'registry' do
  def setup
    MIME::Types.send(:load_default_mime_types)
  end

  describe 'is enumerable' do
    it 'correctly uses an Enumerable method like #any?' do
      assert MIME::Types.any? { |type| type.content_type == 'text/plain' }
    end

    it 'implements each with no parameters to return an Enumerator' do
      assert_kind_of Enumerator, MIME::Types.each
      assert_kind_of Enumerator, MIME::Types.map
    end

    it 'will create a lazy enumerator' do
      assert_kind_of Enumerator::Lazy, MIME::Types.lazy
      assert_kind_of Enumerator::Lazy, MIME::Types.map.lazy
    end

    it 'is countable with an enumerator' do
      assert MIME::Types.each.count > 999
      assert MIME::Types.lazy.count > 999
    end
  end

  describe '.[]' do
    it 'can be searched with a MIME::Type' do
      text_plain = MIME::Type.new('text/plain')
      assert_includes MIME::Types[text_plain], 'text/plain'
      assert_equal 1, MIME::Types[text_plain].size
    end

    it 'can be searched with a regular expression' do
      assert_includes MIME::Types[/plain$/], 'text/plain'
      assert_equal 1, MIME::Types[/plain$/].size
    end

    it 'sorts by priority with multiple matches' do
      assert_equal %w(application/gzip application/x-gzip multipart/x-gzip),
        MIME::Types[/gzip$/]
      assert_equal 3, MIME::Types[/gzip$/].size
    end

    it 'can be searched with a string' do
      assert_includes MIME::Types['text/plain'], 'text/plain'
      assert_equal 1, MIME::Types['text/plain'].size
    end

    it 'can be searched with the complete flag' do
      assert_empty MIME::Types[
        'application/x-www-form-urlencoded',
        complete: true
      ]
      assert_includes MIME::Types['text/plain', complete: true], 'text/plain'
      assert_equal 1, MIME::Types['text/plain', complete: true].size
    end

    it 'can be searched with the registered flag' do
      assert_empty MIME::Types['application/x-wordperfect6.1', registered: true]
      refute_empty MIME::Types[
        'application/x-www-form-urlencoded',
        registered: true
      ]
      refute_empty MIME::Types[/gzip/, registered: true]
      refute_equal MIME::Types[/gzip/], MIME::Types[/gzip/, registered: true]
    end
  end

  describe '.type_for' do
    it 'finds all types for a given extension' do
      assert_equal %w(application/gzip application/x-gzip),
        MIME::Types.type_for('gz')
    end

    it 'separates the extension from filenames' do
      assert_equal %w(image/jpeg), MIME::Types.of(['foo.jpeg', 'bar.jpeg'])
    end

    it 'finds multiple extensions' do
      assert_equal %w(image/jpeg text/plain),
        MIME::Types.type_for(%w(foo.txt foo.jpeg))
    end

    it 'does not find unknown extensions' do
      assert_empty MIME::Types.type_for('zzz')
    end

    it 'modifying type extensions causes reindexing' do
      plain_text = MIME::Types['text/plain'].first
      plain_text.add_extensions('xtxt')
      assert_includes MIME::Types.type_for('xtxt'), 'text/plain'
    end
  end

  describe '.count' do
    it 'can count the number of types inside' do
      assert MIME::Types.count > 999
    end
  end

  describe '.add' do
    def setup
      MIME::Types.instance_variable_set(:@__types__, nil)
      MIME::Types.send(:load_default_mime_types)
    end

    let(:eruby) { MIME::Type.new('application/x-eruby') }
    let(:jinja) { MIME::Type.new('application/jinja2' )}

    it 'successfully adds a new type' do
      MIME::Types.add(eruby)
      assert_equal MIME::Types['application/x-eruby'], [ eruby ]
    end

    it 'complains about adding a duplicate type' do
      MIME::Types.add(eruby)
      assert_output '', /is already registered as a variant/ do
        MIME::Types.add(eruby)
      end
      assert_equal MIME::Types['application/x-eruby'], [eruby]
    end

    it 'does not complain about adding a duplicate type when quiet' do
      MIME::Types.add(eruby)
      assert_silent do
        MIME::Types.add(eruby, :silent)
      end
      assert_equal MIME::Types['application/x-eruby'], [ eruby ]
    end

    it 'successfully adds from an array' do
      MIME::Types.add([ eruby, jinja ])
      assert_equal MIME::Types['application/x-eruby'], [ eruby ]
      assert_equal MIME::Types['application/jinja2'], [ jinja ]
    end

    it 'successfully adds from another MIME::Types' do
      old_count = MIME::Types.count

      mt = MIME::Types.new
      mt.add(eruby)

      MIME::Types.add(mt)
      assert_equal old_count + 1, MIME::Types.count

      assert_equal MIME::Types[eruby.content_type], [ eruby ]
    end
  end
end
