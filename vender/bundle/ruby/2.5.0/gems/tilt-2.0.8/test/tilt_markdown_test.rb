# coding: UTF-8
require 'tilt'
require 'test_helper'

begin
require 'nokogiri'

module MarkdownTests
  def self.included(mod)
    class << mod
      def template(t = nil)
        t.nil? ? @template : @template = t
      end
    end
  end

  def render(text, options = {})
    self.class.template.new(options) { text }.render
  end

  def normalize(html)
    Nokogiri::HTML.fragment(html).to_s.strip
  end

  def nrender(text, options = {})
    html = render(text, options)
    html.encode!("UTF-8") if html.respond_to?(:encode)
    normalize(html)
  end

  def test_escape_html
    html = nrender "Hello <b>World</b>"
    assert_equal "<p>Hello <b>World</b></p>", html
  end

  def test_escape_html_false
    html = nrender "Hello <b>World</b>", :escape_html => false
    assert_equal "<p>Hello <b>World</b></p>", html
  end

  def test_escape_html_true
    html = nrender "Hello <b>World</b>", :escape_html => true
    assert_equal "<p>Hello &lt;b&gt;World&lt;/b&gt;</p>", html
  end

  def test_smart_quotes
    html = nrender 'Hello "World"'
    assert_equal '<p>Hello "World"</p>', html
  end

  def test_smart_quotes_false
    html = nrender 'Hello "World"', :smartypants => false
    assert_equal '<p>Hello "World"</p>', html
  end

  def test_smart_quotes_true
    html = nrender 'Hello "World"', :smartypants => true
    assert_equal '<p>Hello “World”</p>', html
  end

  def test_smarty_pants
    html = nrender "Hello ``World'' -- This is --- a test ..."
    assert_equal "<p>Hello ``World'' -- This is --- a test ...</p>", html
  end

  def test_smarty_pants_false
    html = nrender "Hello ``World'' -- This is --- a test ...", :smartypants => false
    assert_equal "<p>Hello ``World'' -- This is --- a test ...</p>", html
  end
end

begin
  require 'tilt/rdiscount'

  class MarkdownRDiscountTest < Minitest::Test
    include MarkdownTests
    template Tilt::RDiscountTemplate

    def test_smarty_pants_true
      html = nrender "Hello ``World'' -- This is --- a test ...", :smartypants => true
      assert_equal "<p>Hello “World” – This is — a test …</p>", html
    end
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end

begin
  require 'tilt/redcarpet'

  class MarkdownRedcarpetTest < Minitest::Test
    include MarkdownTests
    template Tilt::RedcarpetTemplate

    def test_smarty_pants_true
      # Various versions of Redcarpet support various versions of Smart pants.
      html = nrender "Hello ``World'' -- This is --- a test ...", :smartypants => true
      assert_match %r!<p>Hello “World(''|”) – This is — a test …<\/p>!, html
    end

    def test_renderer_options
      html = nrender "Hello [World](http://example.com)", :smartypants => true, :no_links => true
      assert_equal "<p>Hello [World](http://example.com)</p>", html
    end

    def test_fenced_code_blocks_with_lang
      code = <<-COD.gsub(/^\s+/,"")
      ```ruby
      puts "hello world"
      ```
      COD

      html = nrender code, :fenced_code_blocks => true
      assert_equal %Q{<pre><code class="ruby">puts "hello world"\n</code></pre>}, html
    end
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end

begin
  require 'tilt/bluecloth'

  class MarkdownBlueClothTest < Minitest::Test
    include MarkdownTests
    template Tilt::BlueClothTemplate

    def test_smarty_pants_true
      html = nrender "Hello ``World'' -- This is --- a test ...", :smartypants => true
      assert_equal "<p>Hello “World” — This is —– a test …</p>", html
    end
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end

begin
  require 'tilt/kramdown'

  class MarkdownKramdownTest < Minitest::Test
    include MarkdownTests
    template Tilt::KramdownTemplate
    # Doesn't support escaping
    undef test_escape_html_true
    # Smarty Pants is *always* on, but doesn't support it fully
    undef test_smarty_pants
    undef test_smarty_pants_false
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end


begin
  require 'tilt/maruku'

  class MarkdownMarukuTest < Minitest::Test
    include MarkdownTests
    template Tilt::MarukuTemplate
    # Doesn't support escaping
    undef test_escape_html_true
    # Doesn't support Smarty Pants, and even fails on ``Foobar''
    undef test_smarty_pants
    undef test_smarty_pants_false
    # Smart Quotes is always on
    undef test_smart_quotes
    undef test_smart_quotes_false
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end

rescue LoadError
  warn "Markdown tests need Nokogiri"
end

begin
  require 'tilt/pandoc'

  class MarkdownPandocTest < Minitest::Test
    include MarkdownTests
    template Tilt::PandocTemplate
  end
rescue LoadError => boom
  # It should already be warned in the main tests
end
