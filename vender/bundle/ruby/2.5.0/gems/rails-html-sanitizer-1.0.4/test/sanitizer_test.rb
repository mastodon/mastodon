require "minitest/autorun"
require "rails-html-sanitizer"
require "rails/dom/testing/assertions/dom_assertions"

class SanitizersTest < Minitest::Test
  include Rails::Dom::Testing::Assertions::DomAssertions

  def test_sanitizer_sanitize_raises_not_implemented_error
    assert_raises NotImplementedError do
      Rails::Html::Sanitizer.new.sanitize('')
    end
  end

  def test_sanitize_nested_script
    sanitizer = Rails::Html::WhiteListSanitizer.new
    assert_equal '&lt;script&gt;alert("XSS");&lt;/script&gt;', sanitizer.sanitize('<script><script></script>alert("XSS");<script><</script>/</script><script>script></script>', tags: %w(em))
  end

  def test_sanitize_nested_script_in_style
    sanitizer = Rails::Html::WhiteListSanitizer.new
    assert_equal '&lt;script&gt;alert("XSS");&lt;/script&gt;', sanitizer.sanitize('<style><script></style>alert("XSS");<style><</style>/</style><style>script></style>', tags: %w(em))
  end

  class XpathRemovalTestSanitizer < Rails::Html::Sanitizer
    def sanitize(html, options = {})
      fragment = Loofah.fragment(html)
      remove_xpaths(fragment, options[:xpaths]).to_s
    end
  end

  def test_remove_xpaths_removes_an_xpath
    html = %(<h1>hello <script>code!</script></h1>)
    assert_equal %(<h1>hello </h1>), xpath_sanitize(html, xpaths: %w(.//script))
  end

  def test_remove_xpaths_removes_all_occurrences_of_xpath
    html = %(<section><header><script>code!</script></header><p>hello <script>code!</script></p></section>)
    assert_equal %(<section><header></header><p>hello </p></section>), xpath_sanitize(html, xpaths: %w(.//script))
  end

  def test_remove_xpaths_called_with_faulty_xpath
    assert_raises Nokogiri::XML::XPath::SyntaxError do
      xpath_sanitize('<h1>hello<h1>', xpaths: %w(..faulty_xpath))
    end
  end

  def test_remove_xpaths_called_with_xpath_string
    assert_equal '', xpath_sanitize('<a></a>', xpaths: './/a')
  end

  def test_remove_xpaths_called_with_enumerable_xpaths
    assert_equal '', xpath_sanitize('<a><span></span></a>', xpaths: %w(.//a .//span))
  end

  def test_strip_tags_with_quote
    input = '<" <img src="trollface.gif" onload="alert(1)"> hi'
    assert_equal ' hi', full_sanitize(input)
  end

  def test_strip_invalid_html
    assert_equal "&lt;&lt;", full_sanitize("<<<bad html")
  end

  def test_strip_nested_tags
    expected = "Wei&lt;a onclick='alert(document.cookie);'/&gt;rdos"
    input = "Wei<<a>a onclick='alert(document.cookie);'</a>/>rdos"
    assert_equal expected, full_sanitize(input)
  end

  def test_strip_tags_multiline
    expected = %{This is a test.\n\n\n\nIt no longer contains any HTML.\n}
    input = %{<title>This is <b>a <a href="" target="_blank">test</a></b>.</title>\n\n<!-- it has a comment -->\n\n<p>It no <b>longer <strong>contains <em>any <strike>HTML</strike></em>.</strong></b></p>\n}

    assert_equal expected, full_sanitize(input)
  end

  def test_remove_unclosed_tags
    assert_equal "This is ", full_sanitize("This is <-- not\n a comment here.")
  end

  def test_strip_cdata
    assert_equal "This has a ]]&gt; here.", full_sanitize("This has a <![CDATA[<section>]]> here.")
  end

  def test_strip_unclosed_cdata
    assert_equal "This has an unclosed ]] here...", full_sanitize("This has an unclosed <![CDATA[<section>]] here...")
  end

  def test_strip_blank_string
    assert_nil full_sanitize(nil)
    assert_equal "", full_sanitize("")
    assert_equal "   ", full_sanitize("   ")
  end

  def test_strip_tags_with_plaintext
    assert_equal "Dont touch me", full_sanitize("Dont touch me")
  end

  def test_strip_tags_with_tags
    assert_equal "This is a test.", full_sanitize("<p>This <u>is<u> a <a href='test.html'><strong>test</strong></a>.</p>")
  end

  def test_escape_tags_with_many_open_quotes
    assert_equal "&lt;&lt;", full_sanitize("<<<bad html>")
  end

  def test_strip_tags_with_sentence
    assert_equal "This is a test.", full_sanitize("This is a test.")
  end

  def test_strip_tags_with_comment
    assert_equal "This has a  here.", full_sanitize("This has a <!-- comment --> here.")
  end

  def test_strip_tags_with_frozen_string
    assert_equal "Frozen string with no tags", full_sanitize("Frozen string with no tags".freeze)
  end

  def test_full_sanitize_respect_html_escaping_of_the_given_string
    assert_equal 'test\r\nstring', full_sanitize('test\r\nstring')
    assert_equal '&amp;', full_sanitize('&')
    assert_equal '&amp;', full_sanitize('&amp;')
    assert_equal '&amp;amp;', full_sanitize('&amp;amp;')
    assert_equal 'omg &lt;script&gt;BOM&lt;/script&gt;', full_sanitize('omg &lt;script&gt;BOM&lt;/script&gt;')
  end

  def test_strip_links_with_tags_in_tags
    expected = "&lt;a href='hello'&gt;all <b>day</b> long&lt;/a&gt;"
    input = "<<a>a href='hello'>all <b>day</b> long<</A>/a>"
    assert_equal expected, link_sanitize(input)
  end

  def test_strip_links_with_unclosed_tags
    assert_equal "", link_sanitize("<a<a")
  end

  def test_strip_links_with_plaintext
    assert_equal "Dont touch me", link_sanitize("Dont touch me")
  end

  def test_strip_links_with_line_feed_and_uppercase_tag
    assert_equal "on my mind\nall day long", link_sanitize("<a href='almost'>on my mind</a>\n<A href='almost'>all day long</A>")
  end

  def test_strip_links_leaves_nonlink_tags
    assert_equal "My mind\nall <b>day</b> long", link_sanitize("<a href='almost'>My mind</a>\n<A href='almost'>all <b>day</b> long</A>")
  end

  def test_strip_links_with_links
    assert_equal "0wn3d", link_sanitize("<a href='http://www.rubyonrails.com/'><a href='http://www.rubyonrails.com/' onlclick='steal()'>0wn3d</a></a>")
  end

  def test_strip_links_with_linkception
    assert_equal "Magic", link_sanitize("<a href='http://www.rubyonrails.com/'>Mag<a href='http://www.ruby-lang.org/'>ic")
  end

  def test_strip_links_with_a_tag_in_href
    assert_equal "FrrFox", link_sanitize("<href onlclick='steal()'>FrrFox</a></href>")
  end

  def test_sanitize_form
    assert_sanitized "<form action=\"/foo/bar\" method=\"post\"><input></form>", ''
  end

  def test_sanitize_plaintext
    assert_sanitized "<plaintext><span>foo</span></plaintext>", "<span>foo</span>"
  end

  def test_sanitize_script
    assert_sanitized "a b c<script language=\"Javascript\">blah blah blah</script>d e f", "a b cblah blah blahd e f"
  end

  def test_sanitize_js_handlers
    raw = %{onthis="do that" <a href="#" onclick="hello" name="foo" onbogus="remove me">hello</a>}
    assert_sanitized raw, %{onthis="do that" <a href="#" name="foo">hello</a>}
  end

  def test_sanitize_javascript_href
    raw = %{href="javascript:bang" <a href="javascript:bang" name="hello">foo</a>, <span href="javascript:bang">bar</span>}
    assert_sanitized raw, %{href="javascript:bang" <a name="hello">foo</a>, <span>bar</span>}
  end

  def test_sanitize_image_src
    raw = %{src="javascript:bang" <img src="javascript:bang" width="5">foo</img>, <span src="javascript:bang">bar</span>}
    assert_sanitized raw, %{src="javascript:bang" <img width="5">foo</img>, <span>bar</span>}
  end

  tags = Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS - %w(script form)
  tags.each do |tag_name|
    define_method "test_should_allow_#{tag_name}_tag" do
      scope_allowed_tags(tags) do
        assert_sanitized "start <#{tag_name} title=\"1\" onclick=\"foo\">foo <bad>bar</bad> baz</#{tag_name}> end", %(start <#{tag_name} title="1">foo bar baz</#{tag_name}> end)
      end
    end
  end

  def test_should_allow_anchors
    assert_sanitized %(<a href="foo" onclick="bar"><script>baz</script></a>), %(<a href=\"foo\">baz</a>)
  end

  def test_video_poster_sanitization
    scope_allowed_tags(%w(video)) do
      scope_allowed_attributes %w(src poster) do
        assert_sanitized %(<video src="videofile.ogg" autoplay  poster="posterimage.jpg"></video>), %(<video src="videofile.ogg" poster="posterimage.jpg"></video>)
        assert_sanitized %(<video src="videofile.ogg" poster=javascript:alert(1)></video>), %(<video src="videofile.ogg"></video>)
      end
    end
  end

  # RFC 3986, sec 4.2
  def test_allow_colons_in_path_component
    assert_sanitized "<a href=\"./this:that\">foo</a>"
  end

  %w(src width height alt).each do |img_attr|
    define_method "test_should_allow_image_#{img_attr}_attribute" do
      assert_sanitized %(<img #{img_attr}="foo" onclick="bar" />), %(<img #{img_attr}="foo" />)
    end
  end

  def test_should_handle_non_html
    assert_sanitized 'abc'
  end

  def test_should_handle_blank_text
    [nil, '', '   '].each { |blank| assert_sanitized blank }
  end

  def test_setting_allowed_tags_affects_sanitization
    scope_allowed_tags %w(u) do |sanitizer|
      assert_equal '<u></u>', sanitizer.sanitize('<a><u></u></a>')
    end
  end

  def test_setting_allowed_attributes_affects_sanitization
    scope_allowed_attributes %w(foo) do |sanitizer|
      input = '<a foo="hello" bar="world"></a>'
      assert_equal '<a foo="hello"></a>', sanitizer.sanitize(input)
    end
  end

  def test_custom_tags_overrides_allowed_tags
    scope_allowed_tags %(u) do |sanitizer|
      input = '<a><u></u></a>'
      assert_equal '<a></a>', sanitizer.sanitize(input, tags: %w(a))
    end
  end

  def test_custom_attributes_overrides_allowed_attributes
    scope_allowed_attributes %(foo) do |sanitizer|
      input = '<a foo="hello" bar="world"></a>'
      assert_equal '<a bar="world"></a>', sanitizer.sanitize(input, attributes: %w(bar))
    end
  end

  def test_should_allow_custom_tags
    text = "<u>foo</u>"
    assert_equal text, white_list_sanitize(text, tags: %w(u))
  end

  def test_should_allow_only_custom_tags
    text = "<u>foo</u> with <i>bar</i>"
    assert_equal "<u>foo</u> with bar", white_list_sanitize(text, tags: %w(u))
  end

  def test_should_allow_custom_tags_with_attributes
    text = %(<blockquote cite="http://example.com/">foo</blockquote>)
    assert_equal text, white_list_sanitize(text)
  end

  def test_should_allow_custom_tags_with_custom_attributes
    text = %(<blockquote foo="bar">Lorem ipsum</blockquote>)
    assert_equal text, white_list_sanitize(text, attributes: ['foo'])
  end

  def test_scrub_style_if_style_attribute_option_is_passed
    input = '<p style="color: #000; background-image: url(http://www.ragingplatypus.com/i/cam-full.jpg);"></p>'
    assert_equal '<p style="color: #000;"></p>', white_list_sanitize(input, attributes: %w(style))
  end

  def test_should_raise_argument_error_if_tags_is_not_enumerable
    assert_raises ArgumentError do
      white_list_sanitize('<a>some html</a>', tags: 'foo')
    end
  end

  def test_should_raise_argument_error_if_attributes_is_not_enumerable
    assert_raises ArgumentError do
      white_list_sanitize('<a>some html</a>', attributes: 'foo')
    end
  end

  def test_should_not_accept_non_loofah_inheriting_scrubber
    scrubber = Object.new
    def scrubber.scrub(node); node.name = 'h1'; end

    assert_raises Loofah::ScrubberNotFound do
      white_list_sanitize('<a>some html</a>', scrubber: scrubber)
    end
  end

  def test_should_accept_loofah_inheriting_scrubber
    scrubber = Loofah::Scrubber.new
    def scrubber.scrub(node); node.name = 'h1'; end

    html = "<script>hello!</script>"
    assert_equal "<h1>hello!</h1>", white_list_sanitize(html, scrubber: scrubber)
  end

  def test_should_accept_loofah_scrubber_that_wraps_a_block
    scrubber = Loofah::Scrubber.new { |node| node.name = 'h1' }
    html = "<script>hello!</script>"
    assert_equal "<h1>hello!</h1>", white_list_sanitize(html, scrubber: scrubber)
  end

  def test_custom_scrubber_takes_precedence_over_other_options
    scrubber = Loofah::Scrubber.new { |node| node.name = 'h1' }
    html = "<script>hello!</script>"
    assert_equal "<h1>hello!</h1>", white_list_sanitize(html, scrubber: scrubber, tags: ['foo'])
  end

  [%w(img src), %w(a href)].each do |(tag, attr)|
    define_method "test_should_strip_#{attr}_attribute_in_#{tag}_with_bad_protocols" do
      assert_sanitized %(<#{tag} #{attr}="javascript:bang" title="1">boo</#{tag}>), %(<#{tag} title="1">boo</#{tag}>)
    end
  end

  def test_should_block_script_tag
    assert_sanitized %(<SCRIPT\nSRC=http://ha.ckers.org/xss.js></SCRIPT>), ""
  end

  def test_should_not_fall_for_xss_image_hack_with_uppercase_tags
    assert_sanitized %(<IMG """><SCRIPT>alert("XSS")</SCRIPT>">), %(<img>alert("XSS")"&gt;)
  end

  [%(<IMG SRC="javascript:alert('XSS');">),
   %(<IMG SRC=javascript:alert('XSS')>),
   %(<IMG SRC=JaVaScRiPt:alert('XSS')>),
   %(<IMG SRC=javascript:alert(&quot;XSS&quot;)>),
   %(<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>),
   %(<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>),
   %(<IMG SRC=&#0000106&#0000097&#0000118&#0000097&#0000115&#0000099&#0000114&#0000105&#0000112&#0000116&#0000058&#0000097&#0000108&#0000101&#0000114&#0000116&#0000040&#0000039&#0000088&#0000083&#0000083&#0000039&#0000041>),
   %(<IMG SRC=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>),
   %(<IMG SRC="jav\tascript:alert('XSS');">),
   %(<IMG SRC="jav&#x09;ascript:alert('XSS');">),
   %(<IMG SRC="jav&#x0A;ascript:alert('XSS');">),
   %(<IMG SRC="jav&#x0D;ascript:alert('XSS');">),
   %(<IMG SRC=" &#14;  javascript:alert('XSS');">),
   %(<IMG SRC="javascript&#x3a;alert('XSS');">),
   %(<IMG SRC=`javascript:alert("RSnake says, 'XSS'")`>)].each do |img_hack|
    define_method "test_should_not_fall_for_xss_image_hack_#{img_hack}" do
      assert_sanitized img_hack, "<img>"
    end
  end

  def test_should_sanitize_tag_broken_up_by_null
    assert_sanitized %(<SCR\0IPT>alert(\"XSS\")</SCR\0IPT>), ""
  end

  def test_should_sanitize_invalid_script_tag
    assert_sanitized %(<SCRIPT/XSS SRC="http://ha.ckers.org/xss.js"></SCRIPT>), ""
  end

  def test_should_sanitize_script_tag_with_multiple_open_brackets
    assert_sanitized %(<<SCRIPT>alert("XSS");//<</SCRIPT>), "&lt;alert(\"XSS\");//&lt;"
    assert_sanitized %(<iframe src=http://ha.ckers.org/scriptlet.html\n<a), ""
  end

  def test_should_sanitize_unclosed_script
    assert_sanitized %(<SCRIPT SRC=http://ha.ckers.org/xss.js?<B>), ""
  end

  def test_should_sanitize_half_open_scripts
    assert_sanitized %(<IMG SRC="javascript:alert('XSS')"), "<img>"
  end

  def test_should_not_fall_for_ridiculous_hack
    img_hack = %(<IMG\nSRC\n=\n"\nj\na\nv\na\ns\nc\nr\ni\np\nt\n:\na\nl\ne\nr\nt\n(\n'\nX\nS\nS\n'\n)\n"\n>)
    assert_sanitized img_hack, "<img>"
  end

  def test_should_sanitize_attributes
    assert_sanitized %(<SPAN title="'><script>alert()</script>">blah</SPAN>), %(<span title="#{CGI.escapeHTML "'><script>alert()</script>"}">blah</span>)
  end

  def test_should_sanitize_illegal_style_properties
    raw      = %(display:block; position:absolute; left:0; top:0; width:100%; height:100%; z-index:1; background-color:black; background-image:url(http://www.ragingplatypus.com/i/cam-full.jpg); background-x:center; background-y:center; background-repeat:repeat;)
    expected = %(display:block;width:100%;height:100%;background-color:black;background-x:center;background-y:center;)
    assert_equal expected, sanitize_css(raw)
  end

  def test_should_sanitize_with_trailing_space
    raw = "display:block; "
    expected = "display:block;"
    assert_equal expected, sanitize_css(raw)
  end

  def test_should_sanitize_xul_style_attributes
    raw = %(-moz-binding:url('http://ha.ckers.org/xssmoz.xml#xss'))
    assert_equal '', sanitize_css(raw)
  end

  def test_should_sanitize_invalid_tag_names
    assert_sanitized(%(a b c<script/XSS src="http://ha.ckers.org/xss.js"></script>d e f), "a b cd e f")
  end

  def test_should_sanitize_non_alpha_and_non_digit_characters_in_tags
    assert_sanitized('<a onclick!#$%&()*~+-_.,:;?@[/|\]^`=alert("XSS")>foo</a>', "<a>foo</a>")
  end

  def test_should_sanitize_invalid_tag_names_in_single_tags
    assert_sanitized('<img/src="http://ha.ckers.org/xss.js"/>', "<img />")
  end

  def test_should_sanitize_img_dynsrc_lowsrc
    assert_sanitized(%(<img lowsrc="javascript:alert('XSS')" />), "<img />")
  end

  def test_should_sanitize_div_background_image_unicode_encoded
    raw = %(background-image:\0075\0072\006C\0028'\006a\0061\0076\0061\0073\0063\0072\0069\0070\0074\003a\0061\006c\0065\0072\0074\0028.1027\0058.1053\0053\0027\0029'\0029)
    assert_equal '', sanitize_css(raw)
  end

  def test_should_sanitize_div_style_expression
    raw = %(width: expression(alert('XSS'));)
    assert_equal '', sanitize_css(raw)
  end

  def test_should_sanitize_across_newlines
    raw = %(\nwidth:\nexpression(alert('XSS'));\n)
    assert_equal '', sanitize_css(raw)
  end

  def test_should_sanitize_img_vbscript
    assert_sanitized %(<img src='vbscript:msgbox("XSS")' />), '<img />'
  end

  def test_should_sanitize_cdata_section
    assert_sanitized "<![CDATA[<span>section</span>]]>", "section]]&gt;"
  end

  def test_should_sanitize_unterminated_cdata_section
    assert_sanitized "<![CDATA[<span>neverending...", "neverending..."
  end

  def test_should_not_mangle_urls_with_ampersand
     assert_sanitized %{<a href=\"http://www.domain.com?var1=1&amp;var2=2\">my link</a>}
  end

  def test_should_sanitize_neverending_attribute
    assert_sanitized "<span class=\"\\", "<span class=\"\\\">"
  end

  [
    %(<a href="javascript&#x3a;alert('XSS');">),
    %(<a href="javascript&#x003a;alert('XSS');">),
    %(<a href="javascript&#x3A;alert('XSS');">),
    %(<a href="javascript&#x003A;alert('XSS');">)
  ].each_with_index do |enc_hack, i|
    define_method "test_x03a_handling_#{i+1}" do
      assert_sanitized enc_hack, "<a>"
    end
  end

  def test_x03a_legitimate
    assert_sanitized %(<a href="http&#x3a;//legit">), %(<a href="http://legit">)
    assert_sanitized %(<a href="http&#x3A;//legit">), %(<a href="http://legit">)
  end

  def test_sanitize_ascii_8bit_string
    white_list_sanitize('<a>hello</a>'.encode('ASCII-8BIT')).tap do |sanitized|
      assert_equal '<a>hello</a>', sanitized
      assert_equal Encoding::UTF_8, sanitized.encoding
    end
  end

  def test_sanitize_data_attributes
    assert_sanitized %(<a href="/blah" data-method="post">foo</a>), %(<a href="/blah">foo</a>)
    assert_sanitized %(<a data-remote="true" data-type="script" data-method="get" data-cross-domain="true" href="attack.js">Launch the missiles</a>), %(<a href="attack.js">Launch the missiles</a>)
  end

  def test_allow_data_attribute_if_requested
    text = %(<a data-foo="foo">foo</a>)
    assert_equal %(<a data-foo="foo">foo</a>), white_list_sanitize(text, attributes: ['data-foo'])
  end

  def test_uri_escaping_of_href_attr_in_a_tag_in_white_list_sanitizer
    html = %{<a href='examp<!--" unsafeattr=foo()>-->le.com'>test</a>}

    text = white_list_sanitize(html)

    assert_equal %{<a href="examp<!--%22%20unsafeattr=foo()>-->le.com">test</a>}, text
  end

  def test_uri_escaping_of_src_attr_in_a_tag_in_white_list_sanitizer
    html = %{<a src='examp<!--" unsafeattr=foo()>-->le.com'>test</a>}

    text = white_list_sanitize(html)

    assert_equal %{<a src="examp<!--%22%20unsafeattr=foo()>-->le.com">test</a>}, text
  end

  def test_uri_escaping_of_name_attr_in_a_tag_in_white_list_sanitizer
    html = %{<a name='examp<!--" unsafeattr=foo()>-->le.com'>test</a>}

    text = white_list_sanitize(html)

    assert_equal %{<a name="examp<!--%22%20unsafeattr=foo()>-->le.com">test</a>}, text
  end

  def test_uri_escaping_of_name_action_in_a_tag_in_white_list_sanitizer
    html = %{<a action='examp<!--" unsafeattr=foo()>-->le.com'>test</a>}

    text = white_list_sanitize(html, attributes: ['action'])

    assert_equal %{<a action="examp<!--%22%20unsafeattr=foo()>-->le.com">test</a>}, text
  end

protected

  def xpath_sanitize(input, options = {})
    XpathRemovalTestSanitizer.new.sanitize(input, options)
  end

  def full_sanitize(input, options = {})
    Rails::Html::FullSanitizer.new.sanitize(input, options)
  end

  def link_sanitize(input, options = {})
    Rails::Html::LinkSanitizer.new.sanitize(input, options)
  end

  def white_list_sanitize(input, options = {})
    Rails::Html::WhiteListSanitizer.new.sanitize(input, options)
  end

  def assert_sanitized(input, expected = nil)
    if input
      assert_dom_equal expected || input, white_list_sanitize(input)
    else
      assert_nil white_list_sanitize(input)
    end
  end

  def sanitize_css(input)
    Rails::Html::WhiteListSanitizer.new.sanitize_css(input)
  end

  def scope_allowed_tags(tags)
    old_tags = Rails::Html::WhiteListSanitizer.allowed_tags
    Rails::Html::WhiteListSanitizer.allowed_tags = tags
    yield Rails::Html::WhiteListSanitizer.new
  ensure
    Rails::Html::WhiteListSanitizer.allowed_tags = old_tags
  end

  def scope_allowed_attributes(attributes)
    old_attributes = Rails::Html::WhiteListSanitizer.allowed_attributes
    Rails::Html::WhiteListSanitizer.allowed_attributes = attributes
    yield Rails::Html::WhiteListSanitizer.new
  ensure
    Rails::Html::WhiteListSanitizer.allowed_attributes = old_attributes
  end
end
