#
#  these tests taken from the HTML5 sanitization project and modified for use with Loofah
#  see the original here: http://code.google.com/p/html5lib/source/browse/ruby/test/test_sanitizer.rb
#
#  license text at the bottom of this file
#
require "helper"

class Html5TestSanitizer < Loofah::TestCase
  include Loofah

  def sanitize_xhtml stream
    Loofah.fragment(stream).scrub!(:escape).to_xhtml
  end

  def sanitize_html stream
    Loofah.fragment(stream).scrub!(:escape).to_html
  end

  def check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    ##  libxml uses double-quotes, so let's swappo-boppo our quotes before comparing.
    sane = sanitize_html(input).gsub('"',"'")
    htmloutput = htmloutput.gsub('"',"'")
    xhtmloutput = xhtmloutput.gsub('"',"'")
    rexmloutput = rexmloutput.gsub('"',"'")

    ##  HTML5's parsers are shit. there's so much inconsistency with what has closing tags, etc, that
    ##  it would require a lot of manual hacking to make the tests match libxml's output.
    ##  instead, I'm taking the shotgun approach, and trying to match any of the described outputs.
    assert((htmloutput == sane) || (rexmloutput == sane) || (xhtmloutput == sane),
      %Q{given:    "#{input}"\nexpected: "#{htmloutput}"\ngot:      "#{sane}"})
  end

  def assert_completes_in_reasonable_time &block
    t0 = Time.now
    block.call
    assert_in_delta t0, Time.now, 0.1 # arbitrary seconds
  end

  (HTML5::WhiteList::ALLOWED_ELEMENTS).each do |tag_name|
    define_method "test_should_allow_#{tag_name}_tag" do
      input       = "<#{tag_name} title='1'>foo <bad>bar</bad> baz</#{tag_name}>"
      htmloutput  = "<#{tag_name.downcase} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</#{tag_name}>"
      rexmloutput = xhtmloutput

      if %w[caption colgroup optgroup option tbody td tfoot th thead tr].include?(tag_name)
        htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
      elsif tag_name == 'col'
        htmloutput = "<col title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        rexmloutput = "<col title='1' />"
      elsif tag_name == 'table'
        htmloutput = "foo &lt;bad&gt;bar&lt;/bad&gt;baz<table title='1'> </table>"
        xhtmloutput = htmloutput
      elsif tag_name == 'image'
        htmloutput = "<img title='1'/>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        rexmloutput = "<image title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</image>"
      elsif HTML5::WhiteList::VOID_ELEMENTS.include?(tag_name)
        htmloutput = "<#{tag_name} title='1'>foo &lt;bad&gt;bar&lt;/bad&gt; baz"
        xhtmloutput = htmloutput
        htmloutput += '<br/>' if tag_name == 'br'
        rexmloutput =  "<#{tag_name} title='1' />"
      end
      check_sanitization(input, htmloutput, xhtmloutput, rexmloutput)
    end
  end

  ##
  ##  libxml2 downcases elements, so this is moot.
  ##
  # HTML5::WhiteList::ALLOWED_ELEMENTS.each do |tag_name|
  #   define_method "test_should_forbid_#{tag_name.upcase}_tag" do
  #     input = "<#{tag_name.upcase} title='1'>foo <bad>bar</bad> baz</#{tag_name.upcase}>"
  #     output = "&lt;#{tag_name.upcase} title=\"1\"&gt;foo &lt;bad&gt;bar&lt;/bad&gt; baz&lt;/#{tag_name.upcase}&gt;"
  #     check_sanitization(input, output, output, output)
  #   end
  # end

  HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
    next if attribute_name == 'style'
    define_method "test_should_allow_#{attribute_name}_attribute" do
        input = "<p #{attribute_name}='foo'>foo <bad>bar</bad> baz</p>"
      if %w[checked compact disabled ismap multiple nohref noshade nowrap readonly selected].include?(attribute_name)
        output = "<p #{attribute_name}>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        htmloutput = "<p #{attribute_name.downcase}>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      else
        output = "<p #{attribute_name}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
        htmloutput = "<p #{attribute_name.downcase}='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
      end
      check_sanitization(input, htmloutput, output, output)
    end
  end

  def test_should_allow_data_attributes
    input = "<p data-foo='foo'>foo <bad>bar</bad> baz</p>"

    output = "<p data-foo='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
    htmloutput = "<p data-foo='foo'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, htmloutput, output, output)
  end

  def test_should_allow_multi_word_data_attributes
    input = "<p data-foo-bar-id='11'>foo <bad>bar</bad> baz</p>"
    output = htmloutput = "<p data-foo-bar-id='11'>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"

    check_sanitization(input, htmloutput, output, output)
  end

  ##
  ##  libxml2 downcases attributes, so this is moot.
  ##
  # HTML5::WhiteList::ALLOWED_ATTRIBUTES.each do |attribute_name|
  #   define_method "test_should_forbid_#{attribute_name.upcase}_attribute" do
  #     input = "<p #{attribute_name.upcase}='display: none;'>foo <bad>bar</bad> baz</p>"
  #     output =  "<p>foo &lt;bad&gt;bar&lt;/bad&gt; baz</p>"
  #     check_sanitization(input, output, output, output)
  #   end
  # end

  HTML5::WhiteList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_#{protocol}_uris" do
      input = %(<a href="#{protocol}">foo</a>)
      output = "<a href='#{protocol}'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  HTML5::WhiteList::ALLOWED_PROTOCOLS.each do |protocol|
    define_method "test_should_allow_uppercase_#{protocol}_uris" do
      input = %(<a href="#{protocol.upcase}">foo</a>)
      output = "<a href='#{protocol.upcase}'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  HTML5::WhiteList::ALLOWED_URI_DATA_MEDIATYPES.each do |data_uri_type|
    define_method "test_should_allow_data_#{data_uri_type}_uris" do
      input = %(<a href="data:#{data_uri_type}">foo</a>)
      output = "<a href='data:#{data_uri_type}'>foo</a>"
      check_sanitization(input, output, output, output)

      input = %(<a href="data:#{data_uri_type};base64,R0lGODlhAQABA">foo</a>)
      output = "<a href='data:#{data_uri_type};base64,R0lGODlhAQABA'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  HTML5::WhiteList::ALLOWED_URI_DATA_MEDIATYPES.each do |data_uri_type|
    define_method "test_should_allow_uppercase_data_#{data_uri_type}_uris" do
      input = %(<a href="DATA:#{data_uri_type.upcase}">foo</a>)
      output = "<a href='DATA:#{data_uri_type.upcase}'>foo</a>"
      check_sanitization(input, output, output, output)
    end
  end

  def test_should_disallow_other_uri_mediatypes
    input = %(<a href="data:foo">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output, output, output)

    input = %(<a href="data:image/xxx">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output, output, output)

    input = %(<a href="data:image/xxx;base64,R0lGODlhAQABA">foo</a>)
    output = "<a>foo</a>"
    check_sanitization(input, output, output, output)
  end


  HTML5::WhiteList::SVG_ALLOW_LOCAL_HREF.each do |tag_name|
    next unless HTML5::WhiteList::ALLOWED_ELEMENTS.include?(tag_name)
    define_method "test_#{tag_name}_should_allow_local_href" do
      input = %(<#{tag_name} xlink:href="#foo"/>)
      output = "<#{tag_name.downcase} xlink:href='#foo'></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} xlink:href='#foo'></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_allow_local_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\n#foo"/>)
      output = "<#{tag_name.downcase} xlink:href='\n#foo'></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name} xlink:href='\n#foo'></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href" do
      input = %(<#{tag_name} xlink:href="http://bad.com/foo"/>)
      output = "<#{tag_name.downcase}></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end

    define_method "test_#{tag_name}_should_forbid_nonlocal_href_with_newline" do
      input = %(<#{tag_name} xlink:href="\nhttp://bad.com/foo"/>)
      output = "<#{tag_name.downcase}></#{tag_name.downcase}>"
      xhtmloutput = "<#{tag_name}></#{tag_name}>"
      check_sanitization(input, output, xhtmloutput, xhtmloutput)
    end
  end

  def test_figure_element_is_valid
    fragment = Loofah.scrub_fragment("<span>hello</span> <figure>asd</figure>", :prune)
    assert fragment.at_css("figure"), "<figure> tag was scrubbed"
  end

  ##
  ##  as tenderlove says, "care < 0"
  ##
  # def test_should_handle_astral_plane_characters
  #   input = "<p>&#x1d4b5; &#x1d538;</p>"
  #   output = "<p>\360\235\222\265 \360\235\224\270</p>"
  #   check_sanitization(input, output, output, output)

  #   input = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   output = "<p><tspan>\360\235\224\270</tspan> a</p>"
  #   check_sanitization(input, output, output, output)
  # end

# This affects only NS4. Is it worth fixing?
#  def test_javascript_includes
#    input = %(<div size="&{alert('XSS')}">foo</div>)
#    output = "<div>foo</div>"
#    check_sanitization(input, output, output, output)
#  end

  ##
  ##  these tests primarily test the parser logic, not the sanitizer
  ##  logic. i call bullshit. we're not writing a test suite for
  ##  libxml2 here, so let's rely on the unit tests above to take care
  ##  of our valid elements and attributes.
  ##
  require 'json'
  Dir[File.join(File.dirname(__FILE__), '..', 'assets', 'testdata_sanitizer_tests1.dat')].each do |filename|
    JSON::parse(open(filename).read).each do |test|
      it "testdata sanitizer #{test['name']}" do
        check_sanitization(
          test['input'],
          test['output'],
          test['xhtml'] || test['output'],
          test['rexml'] || test['output']
        )
      end
    end
  end

  ## added because we don't have any coverage above on SVG_ATTR_VAL_ALLOWS_REF
  HTML5::WhiteList::SVG_ATTR_VAL_ALLOWS_REF.each do |attr_name|
    define_method "test_should_allow_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect fill='url(#foo)' />"
      output = "<rect fill='url(#foo)'></rect>"
      check_sanitization(input, output, output, output)
    end

    define_method "test_absolute_uri_refs_in_svg_attribute_#{attr_name}" do
      input = "<rect fill='url(http://bad.com/) #fff' />"
      output = "<rect fill='  #fff'></rect>"
      check_sanitization(input, output, output, output)
    end
  end

  def test_css_negative_value_sanitization
    html = "<span style=\"letter-spacing:-0.03em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert_match %r/-0.03em/, sane.inner_html
  end

  def test_css_negative_value_sanitization_shorthand_css_properties
    html = "<span style=\"margin-left:-0.05em;\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
    assert_match %r/-0.05em/, sane.inner_html
  end

  def test_css_function_sanitization_leaves_whitelisted_functions_calc
    html = "<span style=\"width:calc(5%)\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/calc\(5%\)/, sane.inner_html

    html = "<span style=\"width: calc(5%)\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/calc\(5%\)/, sane.inner_html
  end

  def test_css_function_sanitization_leaves_whitelisted_functions_rgb
    html = '<span style="color: rgb(255, 0, 0)">'
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/rgb\(255, 0, 0\)/, sane.inner_html
  end

  def test_css_function_sanitization_leaves_whitelisted_list_style_type
    html = "<ol style='list-style-type:lower-greek;'></ol>"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/list-style-type:lower-greek/, sane.inner_html
  end

  def test_css_function_sanitization_strips_style_attributes_with_unsafe_functions
    html = "<span style=\"width:attr(data-evil-attr)\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/<span><\/span>/, sane.inner_html

    html = "<span style=\"width: attr(data-evil-attr)\">"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    assert_match %r/<span><\/span>/, sane.inner_html
  end

  def test_issue_90_slow_regex
    skip("timing tests are hard to make pass and have little regression-testing value")

    html = %q{<span style="background: url('data:image/svg&#43;xml;charset=utf-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2232%22%20height%3D%2232%22%20viewBox%3D%220%200%2032%2032%22%3E%3Cpath%20fill%3D%22%23D4C8AE%22%20d%3D%22M0%200h32v32h-32z%22%2F%3E%3Cpath%20fill%3D%22%2383604B%22%20d%3D%22M0%200h31.99v11.75h-31.99z%22%2F%3E%3Cpath%20fill%3D%22%233D2319%22%20d%3D%22M0%2011.5h32v.5h-32z%22%2F%3E%3Cpath%20fill%3D%22%23F83651%22%20d%3D%22M5%200h1v10.5h-1z%22%2F%3E%3Cpath%20fill%3D%22%23FCD050%22%20d%3D%22M6%200h1v10.5h-1z%22%2F%3E%3Cpath%20fill%3D%22%2371C797%22%20d%3D%22M7%200h1v10.5h-1z%22%2F%3E%3Cpath%20fill%3D%22%23509CF9%22%20d%3D%22M8%200h1v10.5h-1z%22%2F%3E%3ClinearGradient%20id%3D%22a%22%20gradientUnits%3D%22userSpaceOnUse%22%20x1%3D%2224.996%22%20y1%3D%2210.5%22%20x2%3D%2224.996%22%20y2%3D%224.5%22%3E%3Cstop%20offset%3D%220%22%20stop-color%3D%22%23796055%22%2F%3E%3Cstop%20offset%3D%22.434%22%20stop-color%3D%22%23614C43%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-color%3D%22%233D2D28%22%2F%3E%3C%2FlinearGradient%3E%3Cpath%20fill%3D%22url(%23a)%22%20d%3D%22M28%208.5c0%201.1-.9%202-2%202h-2c-1.1%200-2-.9-2-2v-2c0-1.1.9-2%202-2h2c1.1%200%202%20.9%202%202v2z%22%2F%3E%3Cpath%20fill%3D%22%235F402E%22%20d%3D%22M28%208c0%201.1-.9%202-2%202h-2c-1.1%200-2-.9-2-2v-2c0-1.1.9-2%202-2h2c1.1%200%202%20.9%202%202v2z%22%2F%3E%3C');"></span>}

    assert_completes_in_reasonable_time {
      Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_html)
    }
  end

  def test_upper_case_css_property
    html = "<div style=\"COLOR: BLUE; NOTAPROPERTY: RED;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_xml)
    assert_match(/COLOR:\s*BLUE/i, sane.at_css("div")["style"])
    refute_match(/NOTAPROPERTY/i, sane.at_css("div")["style"])
  end

  def test_many_properties_some_allowed
    html = "<div style=\"background: bold notaproperty center alsonotaproperty 10px;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_xml)
    assert_match(/bold\s+center\s+10px/, sane.at_css("div")["style"])
  end

  def test_many_properties_non_allowed
    html = "<div style=\"background: notaproperty alsonotaproperty;\">asdf</div>"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_xml)
    assert_nil sane.at_css("div")["style"]
  end

  def test_svg_properties
    html = "<line style='stroke-width: 10px;'></line>"
    sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :strip).to_xml)
    assert_match(/stroke-width:\s*10px/, sane.at_css("line")["style"])
  end
end

# <html5_license>
#
# Copyright (c) 2006-2008 The Authors
#
# Contributors:
# James Graham - jg307@cam.ac.uk
# Anne van Kesteren - annevankesteren@gmail.com
# Lachlan Hunt - lachlan.hunt@lachy.id.au
# Matt McDonald - kanashii@kanashii.ca
# Sam Ruby - rubys@intertwingly.net
# Ian Hickson (Google) - ian@hixie.ch
# Thomas Broyer - t.broyer@ltgt.net
# Jacques Distler - distler@golem.ph.utexas.edu
# Henri Sivonen - hsivonen@iki.fi
# The Mozilla Foundation (contributions from Henri Sivonen since 2008)
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# </html5_license>
