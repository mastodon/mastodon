# encoding: utf-8
require_relative 'common'

describe 'Sanitize::Transformers::CleanElement' do
  make_my_diffs_pretty!
  parallelize_me!

  strings = {
    :basic => {
      :html       => '<b>Lo<!-- comment -->rem</b> <a href="pants" title="foo" style="text-decoration: underline;">ipsum</a> <a href="http://foo.com/"><strong>dolor</strong></a> sit<br/>amet <style>.foo { color: #fff; }</style> <script>alert("hello world");</script>',

      :default    => 'Lorem ipsum dolor sit amet .foo { color: #fff; } alert("hello world");',
      :restricted => '<b>Lorem</b> ipsum <strong>dolor</strong> sit amet .foo { color: #fff; } alert("hello world");',
      :basic      => '<b>Lorem</b> <a href="pants" rel="nofollow">ipsum</a> <a href="http://foo.com/" rel="nofollow"><strong>dolor</strong></a> sit<br>amet .foo { color: #fff; } alert("hello world");',
      :relaxed    => '<b>Lorem</b> <a href="pants" title="foo" style="text-decoration: underline;">ipsum</a> <a href="http://foo.com/"><strong>dolor</strong></a> sit<br>amet <style>.foo { color: #fff; }</style> alert("hello world");'
    },

    :malformed => {
      :html       => 'Lo<!-- comment -->rem</b> <a href=pants title="foo>ipsum <a href="http://foo.com/"><strong>dolor</a></strong> sit<br/>amet <script>alert("hello world");',

      :default    => 'Lorem dolor sit amet alert("hello world");',
      :restricted => 'Lorem <strong>dolor</strong> sit amet alert("hello world");',
      :basic      => 'Lorem <a href="pants" rel="nofollow"><strong>dolor</strong></a> sit<br>amet alert("hello world");',
      :relaxed    => 'Lorem <a href="pants" title="foo&gt;ipsum &lt;a href="><strong>dolor</strong></a> sit<br>amet alert("hello world");',
    },

    :unclosed => {
      :html       => '<p>a</p><blockquote>b',

      :default    => ' a  b ',
      :restricted => ' a  b ',
      :basic      => '<p>a</p><blockquote>b</blockquote>',
      :relaxed    => '<p>a</p><blockquote>b</blockquote>'
    },

    :malicious => {
      :html       => '<b>Lo<!-- comment -->rem</b> <a href="javascript:pants" title="foo">ipsum</a> <a href="http://foo.com/"><strong>dolor</strong></a> sit<br/>amet <<foo>script>alert("hello world");</script>',

      :default    => 'Lorem ipsum dolor sit amet &lt;script&gt;alert("hello world");',
      :restricted => '<b>Lorem</b> ipsum <strong>dolor</strong> sit amet &lt;script&gt;alert("hello world");',
      :basic      => '<b>Lorem</b> <a rel="nofollow">ipsum</a> <a href="http://foo.com/" rel="nofollow"><strong>dolor</strong></a> sit<br>amet &lt;script&gt;alert("hello world");',
      :relaxed    => '<b>Lorem</b> <a title="foo">ipsum</a> <a href="http://foo.com/"><strong>dolor</strong></a> sit<br>amet &lt;script&gt;alert("hello world");'
    }
  }

  protocols = {
    'protocol-based JS injection: simple, no spaces' => {
      :html       => '<a href="javascript:alert(\'XSS\');">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: simple, spaces before' => {
      :html       => '<a href="javascript    :alert(\'XSS\');">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: simple, spaces after' => {
      :html       => '<a href="javascript:    alert(\'XSS\');">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: simple, spaces before and after' => {
      :html       => '<a href="javascript    :   alert(\'XSS\');">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: preceding colon' => {
      :html       => '<a href=":javascript:alert(\'XSS\');">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: UTF-8 encoding' => {
      :html       => '<a href="javascript&#58;">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: long UTF-8 encoding' => {
      :html       => '<a href="javascript&#0058;">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: long UTF-8 encoding without semicolons' => {
      :html       => '<a href=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: hex encoding' => {
      :html       => '<a href="javascript&#x3A;">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: long hex encoding' => {
      :html       => '<a href="javascript&#x003A;">foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: hex encoding without semicolons' => {
      :html       => '<a href=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>foo</a>',
      :default    => 'foo',
      :restricted => 'foo',
      :basic      => '<a rel="nofollow">foo</a>',
      :relaxed    => '<a>foo</a>'
    },

    'protocol-based JS injection: null char' => {
      :html       => "<img src=java\0script:alert(\"XSS\")>",
      :default    => '',
      :restricted => '',
      :basic      => '',
      :relaxed    => '<img>'
    },

    'protocol-based JS injection: invalid URL char' => {
      :html       => '<img src=java\script:alert("XSS")>',
      :default    => '',
      :restricted => '',
      :basic      => '',
      :relaxed    => '<img>'
    },

    'protocol-based JS injection: spaces and entities' => {
      :html       => '<img src=" &#14;  javascript:alert(\'XSS\');">',
      :default    => '',
      :restricted => '',
      :basic      => '',
      :relaxed    => '<img>'
    },

    'protocol whitespace' => {
      :html       => '<a href=" http://example.com/"></a>',
      :default    => '',
      :restricted => '',
      :basic      => '<a href="http://example.com/" rel="nofollow"></a>',
      :relaxed    => '<a href="http://example.com/"></a>'
    }
  }

  describe 'Default config' do
    it 'should remove non-whitelisted elements, leaving safe contents behind' do
      Sanitize.fragment('foo <b>bar</b> <strong><a href="#a">baz</a></strong> quux')
        .must_equal 'foo bar baz quux'

      Sanitize.fragment('<script>alert("<xss>");</script>')
        .must_equal 'alert("&lt;xss&gt;");'

      Sanitize.fragment('<<script>script>alert("<xss>");</<script>>')
        .must_equal '&lt;script&gt;alert("&lt;xss&gt;");&lt;/&lt;script&gt;&gt;'

      Sanitize.fragment('< script <>> alert("<xss>");</script>')
        .must_equal '&lt; script &lt;&gt;&gt; alert("");'
    end

    it 'should surround the contents of :whitespace_elements with space characters when removing the element' do
      Sanitize.fragment('foo<div>bar</div>baz')
        .must_equal 'foo bar baz'

      Sanitize.fragment('foo<br>bar<br>baz')
        .must_equal 'foo bar baz'

      Sanitize.fragment('foo<hr>bar<hr>baz')
        .must_equal 'foo bar baz'
    end

    it 'should not choke on several instances of the same element in a row' do
      Sanitize.fragment('<img src="http://www.google.com/intl/en_ALL/images/logo.gif"><img src="http://www.google.com/intl/en_ALL/images/logo.gif"><img src="http://www.google.com/intl/en_ALL/images/logo.gif"><img src="http://www.google.com/intl/en_ALL/images/logo.gif">')
        .must_equal ''
    end

    strings.each do |name, data|
      it "should clean #{name} HTML" do
        Sanitize.fragment(data[:html]).must_equal(data[:default])
      end
    end

    protocols.each do |name, data|
      it "should not allow #{name}" do
        Sanitize.fragment(data[:html]).must_equal(data[:default])
      end
    end
  end

  describe 'Restricted config' do
    before do
      @s = Sanitize.new(Sanitize::Config::RESTRICTED)
    end

    strings.each do |name, data|
      it "should clean #{name} HTML" do
        @s.fragment(data[:html]).must_equal(data[:restricted])
      end
    end

    protocols.each do |name, data|
      it "should not allow #{name}" do
        @s.fragment(data[:html]).must_equal(data[:restricted])
      end
    end
  end

  describe 'Basic config' do
    before do
      @s = Sanitize.new(Sanitize::Config::BASIC)
    end

    it 'should not choke on valueless attributes' do
      @s.fragment('foo <a href>foo</a> bar')
        .must_equal 'foo <a href rel="nofollow">foo</a> bar'
    end

    it 'should downcase attribute names' do
      @s.fragment('<a HREF="javascript:alert(\'foo\')">bar</a>')
        .must_equal '<a rel="nofollow">bar</a>'
    end

    strings.each do |name, data|
      it "should clean #{name} HTML" do
        @s.fragment(data[:html]).must_equal(data[:basic])
      end
    end

    protocols.each do |name, data|
      it "should not allow #{name}" do
        @s.fragment(data[:html]).must_equal(data[:basic])
      end
    end
  end

  describe 'Relaxed config' do
    before do
      @s = Sanitize.new(Sanitize::Config::RELAXED)
    end

    it 'should encode special chars in attribute values' do
      @s.fragment('<a href="http://example.com" title="<b>&eacute;xamples</b> & things">foo</a>')
        .must_equal '<a href="http://example.com" title="&lt;b&gt;éxamples&lt;/b&gt; &amp; things">foo</a>'
    end

    strings.each do |name, data|
      it "should clean #{name} HTML" do
        @s.fragment(data[:html]).must_equal(data[:relaxed])
      end
    end

    protocols.each do |name, data|
      it "should not allow #{name}" do
        @s.fragment(data[:html]).must_equal(data[:relaxed])
      end
    end
  end

  describe 'Custom configs' do
    it 'should allow attributes on all elements if whitelisted under :all' do
      input = '<p class="foo">bar</p>'

      Sanitize.fragment(input).must_equal ' bar '

      Sanitize.fragment(input, {
        :elements   => ['p'],
        :attributes => {:all => ['class']}
      }).must_equal input

      Sanitize.fragment(input, {
        :elements   => ['p'],
        :attributes => {'div' => ['class']}
      }).must_equal '<p>bar</p>'

      Sanitize.fragment(input, {
        :elements   => ['p'],
        :attributes => {'p' => ['title'], :all => ['class']}
      }).must_equal input
    end

    it "should not allow relative URLs when relative URLs aren't whitelisted" do
      input = '<a href="/foo/bar">Link</a>'

      Sanitize.fragment(input,
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => ['http']}}
      ).must_equal '<a>Link</a>'
    end

    it 'should allow relative URLs containing colons when the colon is not in the first path segment' do
      input = '<a href="/wiki/Special:Random">Random Page</a>'

      Sanitize.fragment(input, {
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => [:relative]}}
      }).must_equal input
    end

    it 'should allow relative URLs containing colons when the colon is part of an anchor' do
      input = '<a href="#fn:1">Footnote 1</a>'

      Sanitize.fragment(input, {
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => [:relative]}}
      }).must_equal input

      input = '<a href="somepage#fn:1">Footnote 1</a>'

      Sanitize.fragment(input, {
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => [:relative]}}
      }).must_equal input
    end

    it 'should remove the contents of filtered nodes when :remove_contents is true' do
      Sanitize.fragment('foo bar <div>baz<span>quux</span></div>',
        :remove_contents => true
      ).must_equal 'foo bar   '
    end

    it 'should remove the contents of specified nodes when :remove_contents is an Array of element names as strings' do
      Sanitize.fragment('foo bar <div>baz<span>quux</span><script>alert("hello!");</script></div>',
        :remove_contents => ['script', 'span']
      ).must_equal 'foo bar  baz '
    end

    it 'should remove the contents of specified nodes when :remove_contents is an Array of element names as symbols' do
      Sanitize.fragment('foo bar <div>baz<span>quux</span><script>alert("hello!");</script></div>',
        :remove_contents => [:script, :span]
      ).must_equal 'foo bar  baz '
    end

    it 'should not allow arbitrary HTML5 data attributes by default' do
      Sanitize.fragment('<b data-foo="bar"></b>',
        :elements => ['b']
      ).must_equal '<b></b>'

      Sanitize.fragment('<b class="foo" data-foo="bar"></b>',
        :attributes => {'b' => ['class']},
        :elements   => ['b']
      ).must_equal '<b class="foo"></b>'
    end

    it 'should allow arbitrary HTML5 data attributes when the :attributes config includes :data' do
      s = Sanitize.new(
        :attributes => {'b' => [:data]},
        :elements   => ['b']
      )

      s.fragment('<b data-foo="valid" data-bar="valid"></b>')
        .must_equal '<b data-foo="valid" data-bar="valid"></b>'

      s.fragment('<b data-="invalid"></b>')
        .must_equal '<b></b>'

      s.fragment('<b data-="invalid"></b>')
        .must_equal '<b></b>'

      s.fragment('<b data-xml="invalid"></b>')
        .must_equal '<b></b>'

      s.fragment('<b data-xmlfoo="invalid"></b>')
        .must_equal '<b></b>'

      s.fragment('<b data-f:oo="valid"></b>')
        .must_equal '<b></b>'

      s.fragment('<b data-f/oo="partial"></b>')
        .must_equal '<b data-f=""></b>' # Nokogiri quirk; not ideal, but harmless

      s.fragment('<b data-éfoo="valid"></b>')
        .must_equal '<b></b>' # Another annoying Nokogiri quirk.
    end

    it 'should replace whitespace_elements with configured :before and :after values' do
      s = Sanitize.new(
        :whitespace_elements => {
          'p'   => { :before => "\n", :after => "\n" },
          'div' => { :before => "\n", :after => "\n" },
          'br'  => { :before => "\n", :after => "\n" },
        }
      )

      s.fragment('<p>foo</p>').must_equal "\nfoo\n"
      s.fragment('<p>foo</p><p>bar</p>').must_equal "\nfoo\n\nbar\n"
      s.fragment('foo<div>bar</div>baz').must_equal "foo\nbar\nbaz"
      s.fragment('foo<br>bar<br>baz').must_equal "foo\nbar\nbaz"
    end

    it 'handles protocols correctly regardless of case' do
      input = '<a href="hTTpS://foo.com/">Text</a>'

      Sanitize.fragment(input, {
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => ['https']}}
      }).must_equal input

      input = '<a href="mailto:someone@example.com?Subject=Hello">Text</a>'

      Sanitize.fragment(input, {
        :elements   => ['a'],
        :attributes => {'a' => ['href']},
        :protocols  => {'a' => {'href' => ['https']}}
      }).must_equal "<a>Text</a>"
    end
  end
end
