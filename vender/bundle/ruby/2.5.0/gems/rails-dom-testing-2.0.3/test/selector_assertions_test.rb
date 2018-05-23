# encoding: utf-8

require 'test_helper'
require 'rails/dom/testing/assertions/selector_assertions'

class AssertSelectTest < ActiveSupport::TestCase
  Assertion = Minitest::Assertion

  include Rails::Dom::Testing::Assertions::SelectorAssertions

  def assert_failure(message, &block)
    e = assert_raises(Assertion, &block)
    assert_match(message, e.message) if Regexp === message
    assert_equal(message, e.message) if String === message
  end

  #
  # Test assert select.
  #

  def test_assert_select
    render_html %Q{<div id="1"></div><div id="2"></div>}
    assert_select "div", 2
    assert_failure(/Expected at least 1 element matching \"p\", found 0/) { assert_select "p" }
  end

  def test_equality_integer
    render_html %Q{<div id="1"></div><div id="2"></div>}
    assert_failure(/Expected exactly 3 elements matching \"div\", found 2/) { assert_select "div", 3 }
    assert_failure(/Expected exactly 0 elements matching \"div\", found 2/) { assert_select "div", 0 }
  end

  def test_equality_true_false
    render_html %Q{<div id="1"></div><div id="2"></div>}
    assert_nothing_raised    { assert_select "div" }
    assert_raise(Assertion) { assert_select "p" }
    assert_nothing_raised    { assert_select "div", true }
    assert_raise(Assertion) { assert_select "p", true }
    assert_raise(Assertion) { assert_select "div", false }
    assert_nothing_raised    { assert_select "p", false }
  end

  def test_equality_false_with_substitution
    render_html %{<a></a>}

    assert_nothing_raised do
      assert_select %{a[href="http://example.org?query=value"]}, false
    end
  end

  def test_equality_false_message
    render_html %Q{<div id="1"></div><div id="2"></div>}
    assert_failure(/Expected exactly 0 elements matching \"div\", found 2/) { assert_select "div", false }
  end

  def test_equality_string_and_regexp
    render_html %Q{<div id="1">foo</div><div id="2">foo</div>}
    assert_nothing_raised    { assert_select "div", "foo" }
    assert_raise(Assertion) { assert_select "div", "bar" }
    assert_nothing_raised    { assert_select "div", :text=>"foo" }
    assert_raise(Assertion) { assert_select "div", :text=>"bar" }
    assert_nothing_raised    { assert_select "div", /(foo|bar)/ }
    assert_raise(Assertion) { assert_select "div", /foobar/ }
    assert_nothing_raised    { assert_select "div", :text=>/(foo|bar)/ }
    assert_raise(Assertion) { assert_select "div", :text=>/foobar/ }
    assert_raise(Assertion) { assert_select "p", :text=>/foobar/ }
  end

  def test_equality_of_html
    render_html %Q{<p>\n<em>"This is <strong>not</strong> a big problem,"</em> he said.\n</p>}
    text = "\"This is not a big problem,\" he said."
    html = "<em>\"This is <strong>not</strong> a big problem,\"</em> he said."
    assert_nothing_raised    { assert_select "p", text }
    assert_raise(Assertion) { assert_select "p", html }
    assert_nothing_raised    { assert_select "p", :html=>html }
    assert_raise(Assertion) { assert_select "p", :html=>text }
    # No stripping for pre.
    render_html %Q{<pre>\n<em>"This is <strong>not</strong> a big problem,"</em> he said.\n</pre>}
    text = "\n\"This is not a big problem,\" he said.\n"
    html = "\n<em>\"This is <strong>not</strong> a big problem,\"</em> he said.\n"
    assert_nothing_raised    { assert_select "pre", text }
    assert_raise(Assertion) { assert_select "pre", html }
    assert_nothing_raised    { assert_select "pre", :html=>html }
    assert_raise(Assertion) { assert_select "pre", :html=>text }
  end

  def test_strip_textarea
    render_html %Q{<textarea>\n\nfoo\n</textarea>}
    assert_select "textarea", "\nfoo\n"
    render_html %Q{<textarea>\nfoo</textarea>}
    assert_select "textarea", "foo"
  end

  def test_counts
    render_html %Q{<div id="1">foo</div><div id="2">foo</div>}
    assert_nothing_raised               { assert_select "div", 2 }
    assert_failure(/Expected exactly 3 elements matching \"div\", found 2/) do
      assert_select "div", 3
    end
    assert_nothing_raised               { assert_select "div", 1..2 }
    assert_failure(/Expected between 3 and 4 elements matching \"div\", found 2/) do
      assert_select "div", 3..4
    end
    assert_nothing_raised               { assert_select "div", :count=>2 }
    assert_failure(/Expected exactly 3 elements matching \"div\", found 2/) do
      assert_select "div", :count=>3
    end
    assert_nothing_raised               { assert_select "div", :minimum=>1 }
    assert_nothing_raised               { assert_select "div", :minimum=>2 }
    assert_failure(/Expected at least 3 elements matching \"div\", found 2/) do
      assert_select "div", :minimum=>3
    end
    assert_nothing_raised               { assert_select "div", :maximum=>2 }
    assert_nothing_raised               { assert_select "div", :maximum=>3 }
    assert_failure(/Expected at most 1 element matching \"div\", found 2/) do
      assert_select "div", :maximum=>1
    end
    assert_nothing_raised               { assert_select "div", :minimum=>1, :maximum=>2 }
    assert_failure(/Expected between 3 and 4 elements matching \"div\", found 2/) do
      assert_select "div", :minimum=>3, :maximum=>4
    end
  end

  def test_substitution_values
    render_html %Q{<div id="1">foo</div><div id="2">foo</div>}
    assert_select "div:match('id', ?)", /\d+/ do |elements|
      assert_equal 2, elements.size
    end
    assert_select "div" do
      assert_select ":match('id', ?)", /\d+/ do |elements|
        assert_equal 2, elements.size
        assert_select "#1"
        assert_select "#2"
      end
    end
  end

  def test_assert_select_root_html
    render_html '<a></a>'

    assert_select 'a'
  end

  def test_assert_select_root_xml
    render_xml '<rss version="2.0"></rss>'

    assert_select 'rss'
  end

  def test_nested_assert_select
    render_html %Q{<div id="1">foo</div><div id="2">foo</div>}
    assert_select "div" do |elements|
      assert_equal 2, elements.size
      assert_select elements, "#1"
      assert_select elements, "#2"
    end
    assert_select "div" do
      assert_select "div" do |elements|
        assert_equal 2, elements.size
        # Testing in a group is one thing
        assert_select "#1,#2"
        # Testing individually is another.
        assert_select "#1"
        assert_select "#2"
        assert_select "#3", false
      end
    end

    assert_failure(/Expected at least 1 element matching \"#4\", found 0\./) do
      assert_select "div" do
        assert_select "#4"
      end
    end
  end

  def test_assert_select_text_match
    render_html %Q{<div id="1"><span>foo</span></div><div id="2"><span>bar</span></div>}
    assert_select "div" do
      assert_nothing_raised    { assert_select "div", "foo" }
      assert_nothing_raised    { assert_select "div", "bar" }
      assert_nothing_raised    { assert_select "div", /\w*/ }
      assert_nothing_raised    { assert_select "div", :text => /\w*/, :count=>2 }
      assert_raise(Assertion)  { assert_select "div", :text=>"foo", :count=>2 }
      assert_nothing_raised    { assert_select "div", :html=>"<span>bar</span>" }
      assert_nothing_raised    { assert_select "div", :html=>"<span>bar</span>" }
      assert_nothing_raised    { assert_select "div", :html=>/\w*/ }
      assert_nothing_raised    { assert_select "div", :html=>/\w*/, :count=>2 }
      assert_raise(Assertion)  { assert_select "div", :html=>"<span>foo</span>", :count=>2 }
    end
  end

  #
  # Test css_select.
  #

  def test_css_select
    render_html %Q{<div id="1"></div><div id="2"></div>}
    assert_equal 2, css_select("div").size
    assert_equal 0, css_select("p").size
  end

  def test_nested_css_select
    render_html %Q{<div id="1">foo</div><div id="2">foo</div>}
    assert_select "div:match('id', ?)", /\d+/ do |elements|
      assert_equal 1, css_select(elements[0], "div").size
      assert_equal 1, css_select(elements[1], "div").size
    end
    assert_select "div" do
      assert_equal 2, css_select("div").size
      css_select("div").each do |element|
        # Testing as a group is one thing
        assert !css_select("#1,#2").empty?
        # Testing individually is another
        assert !css_select("#1").empty?
        assert !css_select("#2").empty?
      end
    end
  end

  # testing invalid selectors
  def test_assert_select_with_invalid_selector
    render_html '<a href="http://example.com">hello</a>'
    assert_raises Nokogiri::CSS::SyntaxError do
      assert_select("[href=http://example.com]")
    end
  end

  def test_css_select_with_invalid_selector
    render_html '<a href="http://example.com">hello</a>'
    assert_raises Nokogiri::CSS::SyntaxError do
      css_select("[href=http://example.com]")
    end
  end

  def test_nested_assert_select_with_match_failure_shows_nice_regex
    render_html %Q{<div id="1">foo</div>}

    error = assert_raises Minitest::Assertion do
      assert_select "div:match('id', ?)", /wups/
    end

    assert_match %Q{div:match('id', /wups/)}, error.message
  end

  def test_feed_item_encoded
    render_xml <<-EOF
<rss version="2.0">
  <channel>
    <item>
      <description>
        <![CDATA[
          <p>Test 1</p>
        ]]>
      </description>
    </item>
    <item>
      <description>
        &lt;p&gt;Test 2&lt;/p&gt;
      </description>
    </item>
  </channel>
</rss>
EOF

    assert_select "channel item description" do

      assert_select_encoded do
        assert_select "p", :count=>2, :text=>/Test/
      end

      # Test individually.
      assert_select "description" do |elements|
        assert_select_encoded elements[0] do
          assert_select "p", "Test 1"
        end
        assert_select_encoded elements[1] do
          assert_select "p", "Test 2"
        end
      end
    end

    # Test that we only un-encode element itself.
    assert_select "channel item" do
      assert_select_encoded do
        assert_select "p", 0
      end
    end
  end

  def test_body_not_present_in_empty_document
    render_html '<div></div>'
    assert_select 'body', 0
  end

  def test_body_class_can_be_tested
    render_html '<body class="foo"></body>'
    assert_select '.foo'
  end

  def test_body_class_can_be_tested_with_html
    render_html '<html><body class="foo"><div></div></body></html>'
    assert_select '.foo'
  end

  protected
    def render_html(html)
      fake_render(:html, html)
    end

    def render_xml(xml)
      fake_render(:xml, xml)
    end

    def fake_render(content_type, content)
      @html_document = if content_type == :xml
        Nokogiri::XML::Document.parse(content)
      else
        Nokogiri::HTML::Document.parse(content)
      end
    end

    def document_root_element
      @html_document.root
    end
end
