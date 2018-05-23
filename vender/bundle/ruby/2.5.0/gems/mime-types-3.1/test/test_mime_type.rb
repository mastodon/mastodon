# -*- ruby encoding: utf-8 -*-

require 'mime/types'
require 'minitest_helper'

describe MIME::Type do
  # it { fail }

  def mime_type(content_type)
    MIME::Type.new(content_type) { |mt| yield mt if block_given? }
  end

  let(:x_appl_x_zip) {
    mime_type('x-appl/x-zip') { |t| t.extensions = %w(zip zp) }
  }
  let(:text_plain) { mime_type('text/plain') }
  let(:text_html) { mime_type('text/html') }
  let(:image_jpeg) { mime_type('image/jpeg') }
  let(:application_javascript) {
    mime_type('application/javascript') do |js|
      js.friendly('en' => 'JavaScript')
      js.xrefs = {
        'rfc' => %w(rfc4239 rfc4239),
        'template' => %w(application/javascript)
      }
      js.encoding = '8bit'
      js.extensions = %w(js sj)
      js.registered = true
    end
  }
  let(:text_x_yaml) {
    mime_type('text/x-yaml') do |yaml|
      yaml.extensions = %w(yaml yml)
      yaml.encoding   = '8bit'
      yaml.friendly('en' => 'YAML Structured Document')
    end
  }
  let(:text_x_yaml_with_docs) {
    text_x_yaml.dup.tap do |yaml|
      yaml.docs = 'Test YAML'
    end
  }

  describe '.simplified' do
    it 'leaves normal types alone' do
      assert_equal 'text/plain', MIME::Type.simplified('text/plain')
    end

    it 'does not remove x- prefixes by default' do
      assert_equal 'application/x-msword',
        MIME::Type.simplified('application/x-msword')
      assert_equal 'x-xyz/abc', MIME::Type.simplified('x-xyz/abc')
    end

    it 'removes x- prefixes when requested' do
      assert_equal 'application/msword',
        MIME::Type.simplified('application/x-msword', remove_x_prefix: true)
      assert_equal 'xyz/abc',
        MIME::Type.simplified('x-xyz/abc', remove_x_prefix: true)
    end

    it 'lowercases mixed-case types' do
      assert_equal 'text/vcard', MIME::Type.simplified('text/vCard')
    end

    it 'returns nil when the value provided is not a valid content type' do
      assert_nil MIME::Type.simplified('text')
    end
  end

  describe '.i18n_key' do
    it 'converts text/plain to text.plain' do
      assert_equal 'text.plain', MIME::Type.i18n_key('text/plain')
    end

    it 'does not remove x-prefixes' do
      assert_equal 'application.x-msword',
        MIME::Type.i18n_key('application/x-msword')
    end

    it 'converts text/vCard to text.vcard' do
      assert_equal 'text.vcard', MIME::Type.i18n_key('text/vCard')
    end

    it 'returns nil when the value provided is not a valid content type' do
      assert_nil MIME::Type.i18n_key('text')
    end
  end

  describe '.new' do
    it 'fails if an invalid content type is provided' do
      exception = assert_raises MIME::Type::InvalidContentType do
        MIME::Type.new('apps')
      end
      assert_equal 'Invalid Content-Type "apps"', exception.to_s
    end

    it 'creates a valid content type just from a string' do
      type = MIME::Type.new('text/x-yaml')

      assert_instance_of MIME::Type, type
      assert_equal 'text/x-yaml', type.content_type
    end

    it 'yields the content type in a block' do
      MIME::Type.new('text/x-yaml') do |type|
        assert_instance_of MIME::Type, type
        assert_equal 'text/x-yaml', type.content_type
      end
    end

    it 'creates a valid content type from a hash' do
      type = MIME::Type.new(
        'content-type' => 'text/x-yaml',
        'obsolete' => true
      )
      assert_instance_of MIME::Type, type
      assert_equal 'text/x-yaml', type.content_type
      assert type.obsolete?
    end

    it 'creates a valid content type from an array' do
      type = MIME::Type.new(%w(text/x-yaml yaml yml yz))
      assert_instance_of MIME::Type, type
      assert_equal 'text/x-yaml', type.content_type
      assert_equal %w(yaml yml yz), type.extensions
    end
  end

  describe '#like?' do
    it 'compares two MIME::Types on #simplified values without x- prefixes' do
      assert text_plain.like?(text_plain)
      refute text_plain.like?(text_html)
    end

    it 'compares MIME::Type against string without x- prefixes' do
      assert text_plain.like?(text_plain.to_s)
      refute text_plain.like?(text_html.to_s)
    end
  end

  describe '#<=>' do
    it 'correctly compares identical types' do
      assert_equal text_plain, text_plain
    end

    it 'correctly compares equivalent types' do
      right = mime_type('text/Plain')
      refute_same text_plain, right
      assert_equal text_plain, right
    end

    it 'correctly compares types that sort earlier' do
      refute_equal text_html, text_plain
      assert_operator text_html, :<, text_plain
    end

    it 'correctly compares types that sort later' do
      refute_equal text_plain, text_html
      assert_operator text_plain, :>, text_html
    end

    it 'correctly compares types against equivalent strings' do
      assert_equal text_plain, 'text/plain'
    end

    it 'correctly compares types against strings that sort earlier' do
      refute_equal text_html, 'text/plain'
      assert_operator text_html, :<, 'text/plain'
    end

    it 'correctly compares types against strings that sort later' do
      refute_equal text_plain, 'text/html'
      assert_operator text_plain, :>, 'text/html'
    end

    it 'correctly compares against nil' do
      refute_equal text_html, nil
      assert_operator text_plain, :<, nil
    end
  end

  describe '#ascii?' do
    it 'defaults to true for text/* types' do
      assert text_plain.ascii?
    end

    it 'defaults to false for non-text/* types' do
      refute image_jpeg.ascii?
    end
  end

  describe '#binary?' do
    it 'defaults to false for text/* types' do
      refute text_plain.binary?
    end

    it 'defaults to true for non-text/* types' do
      assert image_jpeg.binary?
    end
  end

  describe '#complete?' do
    it 'is true when there are extensions' do
      assert text_x_yaml.complete?
    end

    it 'is false when there are no extensions' do
      refute mime_type('text/plain').complete?
    end
  end

  describe '#content_type' do
    it 'preserves the original case' do
      assert_equal 'text/plain', text_plain.content_type
      assert_equal 'text/vCard', mime_type('text/vCard').content_type
    end

    it 'does not remove x- prefixes' do
      assert_equal 'x-appl/x-zip', x_appl_x_zip.content_type
    end
  end

  describe '#default_encoding' do
    it 'is quoted-printable for text/* types' do
      assert_equal 'quoted-printable', text_plain.default_encoding
    end

    it 'is base64 for non-text/* types' do
      assert_equal 'base64', image_jpeg.default_encoding
    end
  end

  describe '#encoding, #encoding=' do
    it 'returns #default_encoding if not set explicitly' do
      assert_equal 'quoted-printable', text_plain.encoding
      assert_equal 'base64', image_jpeg.encoding
    end

    it 'returns the set value when set' do
      text_plain.encoding = '8bit'
      assert_equal '8bit', text_plain.encoding
    end

    it 'resets to the default encoding when set to nil or :default' do
      text_plain.encoding = '8bit'
      text_plain.encoding = nil
      assert_equal text_plain.default_encoding, text_plain.encoding
      text_plain.encoding = :default
      assert_equal text_plain.default_encoding, text_plain.encoding
    end

    it 'raises a MIME::Type::InvalidEncoding for an invalid encoding' do
      exception = assert_raises MIME::Type::InvalidEncoding do
        text_plain.encoding = 'binary'
      end
      assert_equal 'Invalid Encoding "binary"', exception.to_s
    end
  end

  describe '#eql?' do
    it 'is not true for a non-MIME::Type' do
      refute text_plain.eql?('text/plain')
    end

    it 'is not true for a different MIME::Type' do
      refute text_plain.eql?(image_jpeg)
    end

    it 'is true for an equivalent MIME::Type' do
      assert text_plain, mime_type('text/Plain')
    end
  end

  describe '#extensions, #extensions=' do
    it 'returns an array of extensions' do
      assert_equal %w(yaml yml), text_x_yaml.extensions
      assert_equal %w(zip zp), x_appl_x_zip.extensions
    end

    it 'sets a single extension when provided a single value' do
      text_x_yaml.extensions = 'yaml'
      assert_equal %w(yaml), text_x_yaml.extensions
    end

    it 'deduplicates extensions' do
      text_x_yaml.extensions = %w(yaml yaml)
      assert_equal %w(yaml), text_x_yaml.extensions
    end
  end

  describe '#add_extensions' do
    it 'does not modify extensions when provided nil' do
      text_x_yaml.add_extensions(nil)
      assert_equal %w(yaml yml), text_x_yaml.extensions
    end

    it 'remains deduplicated with duplicate values' do
      text_x_yaml.add_extensions('yaml')
      assert_equal %w(yaml yml), text_x_yaml.extensions
      text_x_yaml.add_extensions(%w(yaml yz))
      assert_equal %w(yaml yml yz), text_x_yaml.extensions
    end
  end

  describe '#priority_compare' do
    def assert_priority_less(left, right)
      assert_equal(-1, left.priority_compare(right))
    end

    def assert_priority_same(left, right)
      assert_equal 0, left.priority_compare(right)
    end

    def assert_priority_more(left, right)
      assert_equal 1, left.priority_compare(right)
    end

    def assert_priority(left, middle, right)
      assert_priority_less left, right
      assert_priority_same left, middle
      assert_priority_more right, left
    end

    let(:text_1) { mime_type('text/1') }
    let(:text_1p) { mime_type('text/1') }
    let(:text_2) { mime_type('text/2') }

    it 'sorts (1) based on the simplified type' do
      assert_priority text_1, text_1p, text_2
    end

    it 'sorts (2) based on the registration state' do
      text_1.registered = text_1p.registered = true
      text_1b = mime_type(text_1) { |t| t.registered = false }

      assert_priority text_1, text_1p, text_1b
    end

    it 'sorts (3) based on the completeness' do
      text_1.extensions = text_1p.extensions = '1'
      text_1b = mime_type(text_1) { |t| t.extensions = nil }

      assert_priority text_1, text_1p, text_1b
    end

    it 'sorts (4) based on obsolete status' do
      text_1.obsolete = text_1p.obsolete = false
      text_1b = mime_type(text_1) { |t| t.obsolete = true }

      assert_priority text_1, text_1p, text_1b
    end

    it 'sorts (5) based on the use-instead value' do
      text_1.obsolete = text_1p.obsolete = true
      text_1.use_instead = text_1p.use_instead = 'abc/xyz'
      text_1b = mime_type(text_1) { |t| t.use_instead = nil }

      assert_priority text_1, text_1p, text_1b

      text_1b.use_instead = 'abc/zzz'

      assert_priority text_1, text_1p, text_1b
    end
  end

  describe '#raw_media_type' do
    it 'extracts the media type as case-preserved' do
      assert_equal 'Text', mime_type('Text/plain').raw_media_type
    end

    it 'does not remove x- prefixes' do
      assert_equal('x-appl', x_appl_x_zip.raw_media_type)
    end
  end

  describe '#media_type' do
    it 'extracts the media type as lowercase' do
      assert_equal 'text', text_plain.media_type
    end

    it 'does not remove x- prefixes' do
      assert_equal('x-appl', x_appl_x_zip.media_type)
    end
  end

  describe '#raw_media_type' do
    it 'extracts the media type as case-preserved' do
      assert_equal 'Text', mime_type('Text/plain').raw_media_type
    end

    it 'does not remove x- prefixes' do
      assert_equal('x-appl', x_appl_x_zip.raw_media_type)
    end
  end

  describe '#sub_type' do
    it 'extracts the sub type as lowercase' do
      assert_equal 'plain', text_plain.sub_type
    end

    it 'does not remove x- prefixes' do
      assert_equal('x-zip', x_appl_x_zip.sub_type)
    end
  end

  describe '#raw_sub_type' do
    it 'extracts the sub type as case-preserved' do
      assert_equal 'Plain', mime_type('text/Plain').raw_sub_type
    end

    it 'does not remove x- prefixes' do
      assert_equal('x-zip', x_appl_x_zip.raw_sub_type)
    end
  end

  describe '#to_h' do
    let(:t) { mime_type('a/b') }

    it 'has the required keys (content-type, registered, encoding)' do
      assert_has_keys t.to_h, %w(content-type registered encoding)
    end

    it 'has the docs key if there are documents' do
      assert_has_keys mime_type(t) { |v| v.docs = 'a' }.to_h, %w(docs)
    end

    it 'has the extensions key if set' do
      assert_has_keys mime_type(t) { |v| v.extensions = 'a' }.to_h,
        'extensions'
    end

    it 'has the preferred-extension key if set' do
      assert_has_keys mime_type(t) { |v| v.preferred_extension = 'a' }.to_h,
        'preferred-extension'
    end

    it 'has the obsolete key if set' do
      assert_has_keys mime_type(t) { |v| v.obsolete = true }.to_h, 'obsolete'
    end

    it 'has the obsolete and use-instead keys if set' do
      assert_has_keys mime_type(t) { |v|
        v.obsolete = true
        v.use_instead = 'c/d'
      }.to_h, %w(obsolete use-instead)
    end

    it 'has the signature key if set' do
      assert_has_keys mime_type(t) { |v| v.signature = true }.to_h, 'signature'
    end
  end

  describe '#to_json' do
    let(:expected) {
      '{"content-type":"a/b","encoding":"base64","registered":false}'
    }

    it 'converts to JSON when requested' do
      assert_equal expected, mime_type('a/b').to_json
    end
  end

  describe '#to_s, #to_str' do
    it 'represents itself as a string of the canonical content_type' do
      assert_equal 'text/plain', "#{text_plain}"
    end

    it 'acts like a string of the canonical content_type for comparison' do
      assert_equal text_plain, 'text/plain'
    end

    it 'acts like a string for other purposes' do
      assert_equal 'stringy', 'text/plain'.sub(text_plain, 'stringy')
    end
  end

  describe '#xrefs, #xrefs=' do
    let(:expected) {
      {
        'rfc' => Set[*%w(rfc1234 rfc5678)]
      }
    }

    it 'returns the expected results' do
      application_javascript.xrefs = {
        'rfc' => %w(rfc5678 rfc1234 rfc1234)
      }

      assert_equal expected, application_javascript.xrefs
    end
  end

  describe '#xref_urls' do
    let(:expected) {
      [
        'http://www.iana.org/go/draft1',
        'http://www.iana.org/assignments/media-types/a/b',
        'http://www.iana.org/assignments/media-types/media-types.xhtml#p-1',
        'http://www.iana.org/go/rfc-1',
        'http://www.rfc-editor.org/errata_search.php?eid=err-1',
        'http://example.org',
        'text'
      ]
    }

    let(:type) {
      mime_type('a/b').tap do |t|
        t.xrefs = {
          'draft'      => [ 'RFC1' ],
          'template'   => [ 'a/b' ],
          'person'     => [ 'p-1' ],
          'rfc'        => [ 'rfc-1' ],
          'rfc-errata' => [ 'err-1' ],
          'uri'        => [ 'http://example.org' ],
          'text'       => [ 'text' ]
        }
      end
    }

    it 'translates according to given rules' do
      assert_equal expected, type.xref_urls
    end
  end

  describe '#use_instead' do
    it 'is nil unless the type is obsolete' do
      assert_nil text_plain.use_instead
    end

    it 'is nil if not set and the type is obsolete' do
      text_plain.obsolete = true
      assert_nil text_plain.use_instead
    end

    it 'is a different type if set and the type is obsolete' do
      text_plain.obsolete = true
      text_plain.use_instead = 'text/html'
      assert_equal 'text/html', text_plain.use_instead
    end
  end

  describe '#preferred_extension, #preferred_extension=' do
    it 'is nil when not set and there are no extensions' do
      assert_nil text_plain.preferred_extension
    end

    it 'is the first extension when not set but there are extensions' do
      assert_equal 'yaml', text_x_yaml.preferred_extension
    end

    it 'is the extension provided when set' do
      text_x_yaml.preferred_extension = 'yml'
      assert_equal 'yml', text_x_yaml.preferred_extension
    end

    it 'is adds the preferred extension if it does not exist' do
      text_x_yaml.preferred_extension = 'yz'
      assert_equal 'yz', text_x_yaml.preferred_extension
      assert_includes text_x_yaml.extensions, 'yz'
    end
  end

  describe '#friendly' do
    it 'returns English by default' do
      assert_equal 'YAML Structured Document', text_x_yaml.friendly
    end

    it 'returns English when requested' do
      assert_equal 'YAML Structured Document', text_x_yaml.friendly('en')
      assert_equal 'YAML Structured Document', text_x_yaml.friendly(:en)
    end

    it 'returns nothing for an unknown language' do
      assert_nil text_x_yaml.friendly('zz')
    end

    it 'merges new values from an array parameter' do
      expected = { 'en' => 'Text files' }
      assert_equal expected, text_plain.friendly([ 'en', 'Text files' ])
      expected.update('fr' => 'des fichiers texte')
      assert_equal expected,
        text_plain.friendly([ 'fr', 'des fichiers texte' ])
    end

    it 'merges new values from a hash parameter' do
      expected = { 'en' => 'Text files' }
      assert_equal expected, text_plain.friendly(expected)
      french = { 'fr' => 'des fichiers texte' }
      expected.update(french)
      assert_equal expected, text_plain.friendly(french)
    end

    it 'raises an ArgumentError if an unknown value is provided' do
      exception = assert_raises ArgumentError do
        text_plain.friendly(1)
      end

      assert_equal 'Expected a language or translation set, not 1',
        exception.message
    end
  end
end
