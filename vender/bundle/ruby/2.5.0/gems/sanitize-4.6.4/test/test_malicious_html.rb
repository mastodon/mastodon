# encoding: utf-8
require_relative 'common'

# Miscellaneous attempts to sneak maliciously crafted HTML past Sanitize. Many
# of these are courtesy of (or inspired by) the OWASP XSS Filter Evasion Cheat
# Sheet.
#
# https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet

describe 'Malicious HTML' do
  make_my_diffs_pretty!
  parallelize_me!

  before do
    @s = Sanitize.new(Sanitize::Config::RELAXED)
  end

  describe 'comments' do
    it 'should not allow script injection via conditional comments' do
      @s.fragment(%[<!--[if gte IE 4]>\n<script>alert('XSS');</script>\n<![endif]-->]).
        must_equal ''
    end
  end

  describe 'interpolation (ERB, PHP, etc.)' do
    it 'should escape ERB-style tags' do
      @s.fragment('<% naughty_ruby_code %>').
        must_equal '&lt;% naughty_ruby_code %&gt;'

      @s.fragment('<%= naughty_ruby_code %>').
        must_equal '&lt;%= naughty_ruby_code %&gt;'
    end

    it 'should remove PHP-style tags' do
      @s.fragment('<? naughtyPHPCode(); ?>').
        must_equal ''

      @s.fragment('<?= naughtyPHPCode(); ?>').
        must_equal ''
    end
  end

  describe '<body>' do
    it 'should not be possible to inject JS via a malformed event attribute' do
      @s.document('<html><head></head><body onload!#$%&()*~+-_.,:;?@[/|\\]^`=alert("XSS")></body></html>').
        must_equal "<html><head></head><body></body></html>\n"
    end
  end

  describe '<iframe>' do
    it 'should not be possible to inject an iframe using an improperly closed tag' do
      @s.fragment(%[<iframe src=http://ha.ckers.org/scriptlet.html <]).
        must_equal ''
    end
  end

  describe '<img>' do
    it 'should not be possible to inject JS via an unquoted <img> src attribute' do
      @s.fragment("<img src=javascript:alert('XSS')>").must_equal '<img>'
    end

    it 'should not be possible to inject JS using grave accents as <img> src delimiters' do
      @s.fragment("<img src=`javascript:alert('XSS')`>").must_equal '<img>'
    end

    it 'should not be possible to inject <script> via a malformed <img> tag' do
      @s.fragment('<img """><script>alert("XSS")</script>">').
        must_equal '<img>alert("XSS")"&gt;'
    end

    it 'should not be possible to inject protocol-based JS' do
      @s.fragment('<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>').
        must_equal '<img>'

      @s.fragment('<img src=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>').
        must_equal '<img>'

      @s.fragment('<img src=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>').
        must_equal '<img>'

      # Encoded tab character.
      @s.fragment(%[<img src="jav&#x09;ascript:alert('XSS');">]).
        must_equal '<img>'

      # Encoded newline.
      @s.fragment(%[<img src="jav&#x0A;ascript:alert('XSS');">]).
        must_equal '<img>'

      # Encoded carriage return.
      @s.fragment(%[<img src="jav&#x0D;ascript:alert('XSS');">]).
        must_equal '<img>'

      # Null byte.
      @s.fragment(%[<img src=java\0script:alert("XSS")>]).
        must_equal '<img>'

      # Spaces plus meta char.
      @s.fragment(%[<img src=" &#14;  javascript:alert('XSS');">]).
        must_equal '<img>'

      # Mixed spaces and tabs.
      @s.fragment(%[<img src="j\na v\tascript://alert('XSS');">]).
        must_equal '<img>'
    end

    it 'should not be possible to inject protocol-based JS via whitespace' do
      @s.fragment(%[<img src="jav\tascript:alert('XSS');">]).
        must_equal '<img>'
    end

    it 'should not be possible to inject JS using a half-open <img> tag' do
      @s.fragment(%[<img src="javascript:alert('XSS')"]).
        must_equal ''
    end
  end

  describe '<script>' do
    it 'should not be possible to inject <script> using a malformed non-alphanumeric tag name' do
      @s.fragment(%[<script/xss src="http://ha.ckers.org/xss.js">alert(1)</script>]).
        must_equal 'alert(1)'
    end

    it 'should not be possible to inject <script> via extraneous open brackets' do
      @s.fragment(%[<<script>alert("XSS");//<</script>]).
        must_equal '&lt;alert("XSS");//&lt;'
    end
  end

  # libxml2 >= 2.9.2 doesn't escape comments within some attributes, in an
  # attempt to preserve server-side includes. This can result in XSS since an
  # unescaped double quote can allow an attacker to inject a non-whitelisted
  # attribute. Sanitize works around this by implementing its own escaping for
  # affected attributes.
  #
  # The relevant libxml2 code is here:
  # <https://github.com/GNOME/libxml2/commit/960f0e275616cadc29671a218d7fb9b69eb35588>
  describe 'unsafe libxml2 server-side includes in attributes' do
    tag_configs = [
      {
        tag_name: 'a',
        escaped_attrs: %w[ action href src name ],
        unescaped_attrs: []
      },

      {
        tag_name: 'div',
        escaped_attrs: %w[ action href src ],
        unescaped_attrs: %w[ name ]
      }
    ]

    before do
      @s = Sanitize.new({
        elements: %w[ a div ],

        attributes: {
          all: %w[ action href src name ]
        }
      })
    end

    tag_configs.each do |tag_config|
      tag_name = tag_config[:tag_name]

      tag_config[:escaped_attrs].each do |attr_name|
        input = %[<#{tag_name} #{attr_name}='examp<!--" onmouseover=alert(1)>-->le.com'>foo</#{tag_name}>]

        it 'should escape unsafe characters in attributes' do
          @s.fragment(input).must_equal(%[<#{tag_name} #{attr_name}="examp<!--%22%20onmouseover=alert(1)>-->le.com">foo</#{tag_name}>])
        end

        it 'should round-trip to the same output' do
          output = @s.fragment(input)
          @s.fragment(output).must_equal(output)
        end
      end

      tag_config[:unescaped_attrs].each do |attr_name|
        input = %[<#{tag_name} #{attr_name}='examp<!--" onmouseover=alert(1)>-->le.com'>foo</#{tag_name}>]

        it 'should not escape characters unnecessarily' do
          @s.fragment(input).must_equal(input)
        end

        it 'should round-trip to the same output' do
          output = @s.fragment(input)
          @s.fragment(output).must_equal(output)
        end
      end
    end
  end
end
