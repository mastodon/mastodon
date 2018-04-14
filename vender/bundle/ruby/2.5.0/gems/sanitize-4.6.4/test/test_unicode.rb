# encoding: utf-8
require_relative 'common'

describe 'Unicode' do
  make_my_diffs_pretty!
  parallelize_me!

  # http://www.w3.org/TR/unicode-xml/#Charlist
  describe 'Unsuitable characters' do
    before do
      @s = Sanitize.new(Sanitize::Config::RELAXED)
    end

    it 'should not modify the input string' do
      fragment = "a\u0340b\u0341c"
      document = "a\u0340b\u0341c"

      @s.document(document)
      @s.fragment(fragment)

      fragment.must_equal "a\u0340b\u0341c"
      document.must_equal "a\u0340b\u0341c"
    end

    it 'should strip deprecated grave and acute clones' do
      @s.document("a\u0340b\u0341c").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u0340b\u0341c").must_equal 'abc'
    end

    it 'should strip deprecated Khmer characters' do
      @s.document("a\u17a3b\u17d3c").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u17a3b\u17d3c").must_equal 'abc'
    end

    it 'should strip line and paragraph separator punctuation' do
      @s.document("a\u2028b\u2029c").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u2028b\u2029c").must_equal 'abc'
    end

    it 'should strip bidi embedding control characters' do
      @s.document("a\u202ab\u202bc\u202cd\u202de\u202e")
        .must_equal "<html><head></head><body>abcde</body></html>\n"

      @s.fragment("a\u202ab\u202bc\u202cd\u202de\u202e")
        .must_equal 'abcde'
    end

    it 'should strip deprecated symmetric swapping characters' do
      @s.document("a\u206ab\u206bc").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u206ab\u206bc").must_equal 'abc'
    end

    it 'should strip deprecated Arabic form shaping characters' do
      @s.document("a\u206cb\u206dc").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u206cb\u206dc").must_equal 'abc'
    end

    it 'should strip deprecated National digit shape characters' do
      @s.document("a\u206eb\u206fc").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\u206eb\u206fc").must_equal 'abc'
    end

    it 'should strip interlinear annotation characters' do
      @s.document("a\ufff9b\ufffac\ufffb").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\ufff9b\ufffac\ufffb").must_equal 'abc'
    end

    it 'should strip BOM/zero-width non-breaking space characters' do
      @s.document("a\ufeffbc").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\ufeffbc").must_equal 'abc'
    end

    it 'should strip object replacement characters' do
      @s.document("a\ufffcbc").must_equal "<html><head></head><body>abc</body></html>\n"
      @s.fragment("a\ufffcbc").must_equal 'abc'
    end

    it 'should strip musical notation scoping characters' do
      @s.document("a\u{1d173}b\u{1d174}c\u{1d175}d\u{1d176}e\u{1d177}f\u{1d178}g\u{1d179}h\u{1d17a}")
        .must_equal "<html><head></head><body>abcdefgh</body></html>\n"

      @s.fragment("a\u{1d173}b\u{1d174}c\u{1d175}d\u{1d176}e\u{1d177}f\u{1d178}g\u{1d179}h\u{1d17a}")
        .must_equal 'abcdefgh'
    end

    it 'should strip language tag code point characters' do
      str = String.new 'a'
      (0xE0000..0xE007F).each {|n| str << [n].pack('U') }
      str << 'b'

      @s.document(str).must_equal "<html><head></head><body>ab</body></html>\n"
      @s.fragment(str).must_equal 'ab'
    end
  end
end
