# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Types do
  def mime_types
    @mime_types ||= MIME::Types.new.tap do |mt|
      mt.add MIME::Type.new(['text/plain', %w(txt)]),
        MIME::Type.new(['image/jpeg', %w(jpg jpeg)]),
        MIME::Type.new('application/x-wordperfect6.1'),
        MIME::Type.new(
          'content-type' => 'application/x-www-form-urlencoded',
          'registered' => true
        ),
        MIME::Type.new(['application/x-gzip', %w(gz)]),
        MIME::Type.new(
          'content-type' => 'application/gzip',
          'extensions' => 'gz',
          'registered' => true
        )
    end
  end

  describe 'is enumerable' do
    it 'correctly uses an Enumerable method like #any?' do
      assert mime_types.any? { |type| type.content_type == 'text/plain' }
    end

    it 'implements each with no parameters to return an Enumerator' do
      assert_kind_of Enumerator, mime_types.each
      assert_kind_of Enumerator, mime_types.map
    end

    it 'will create a lazy enumerator' do
      assert_kind_of Enumerator::Lazy, mime_types.lazy
      assert_kind_of Enumerator::Lazy, mime_types.map.lazy
    end

    it 'is countable with an enumerator' do
      assert_equal 6, mime_types.each.count
      assert_equal 6, mime_types.lazy.count
    end
  end

  describe '#[]' do
    it 'can be searched with a MIME::Type' do
      text_plain = MIME::Type.new('text/plain')
      assert_includes mime_types[text_plain], 'text/plain'
      assert_equal 1, mime_types[text_plain].size
    end

    it 'can be searched with a regular expression' do
      assert_includes mime_types[/plain$/], 'text/plain'
      assert_equal 1, mime_types[/plain$/].size
    end

    it 'sorts by priority with multiple matches' do
      assert_equal %w(application/gzip application/x-gzip), mime_types[/gzip$/]
      assert_equal 2, mime_types[/gzip$/].size
    end

    it 'can be searched with a string' do
      assert_includes mime_types['text/plain'], 'text/plain'
      assert_equal 1, mime_types['text/plain'].size
    end

    it 'can be searched with the complete flag' do
      assert_empty mime_types[
        'application/x-www-form-urlencoded',
        complete: true
      ]
      assert_includes mime_types['text/plain', complete: true], 'text/plain'
      assert_equal 1, mime_types['text/plain', complete: true].size
    end

    it 'can be searched with the registered flag' do
      assert_empty mime_types['application/x-wordperfect6.1', registered: true]
      refute_empty mime_types[
        'application/x-www-form-urlencoded',
        registered: true
      ]
      refute_empty mime_types[/gzip/, registered: true]
      refute_equal mime_types[/gzip/], mime_types[/gzip/, registered: true]
    end
  end

  describe '#add' do
    let(:eruby) { MIME::Type.new('application/x-eruby') }
    let(:jinja) { MIME::Type.new('application/jinja2' )}

    it 'successfully adds a new type' do
      mime_types.add(eruby)
      assert_equal mime_types['application/x-eruby'], [ eruby ]
    end

    it 'complains about adding a duplicate type' do
      mime_types.add(eruby)
      assert_output '', /is already registered as a variant/ do
        mime_types.add(eruby)
      end
      assert_equal mime_types['application/x-eruby'], [eruby]
    end

    it 'does not complain about adding a duplicate type when quiet' do
      mime_types.add(eruby)
      assert_output '', '' do
        mime_types.add(eruby, :silent)
      end
      assert_equal mime_types['application/x-eruby'], [ eruby ]
    end

    it 'successfully adds from an array' do
      mime_types.add([ eruby, jinja ])
      assert_equal mime_types['application/x-eruby'], [ eruby ]
      assert_equal mime_types['application/jinja2'], [ jinja ]
    end

    it 'successfully adds from another MIME::Types' do
      mt = MIME::Types.new
      mt.add(mime_types)
      assert_equal mime_types.count, mt.count

      mime_types.each do |type|
        assert_equal mt[type.content_type], [ type ]
      end
    end
  end

  describe '#type_for' do
    it 'finds all types for a given extension' do
      assert_equal %w(application/gzip application/x-gzip),
        mime_types.type_for('gz')
    end

    it 'separates the extension from filenames' do
      assert_equal %w(image/jpeg), mime_types.of(['foo.jpeg', 'bar.jpeg'])
    end

    it 'finds multiple extensions' do
      assert_equal %w(image/jpeg text/plain),
        mime_types.type_for(%w(foo.txt foo.jpeg))
    end

    it 'does not find unknown extensions' do
      assert_empty mime_types.type_for('zzz')
    end

    it 'modifying type extensions causes reindexing' do
      plain_text = mime_types['text/plain'].first
      plain_text.add_extensions('xtxt')
      assert_includes mime_types.type_for('xtxt'), 'text/plain'
    end
  end

  describe '#count' do
    it 'can count the number of types inside' do
      assert_equal 6, mime_types.count
    end
  end
end
