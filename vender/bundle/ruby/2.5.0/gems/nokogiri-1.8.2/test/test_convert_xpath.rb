require "helper"

class TestConvertXPath < Nokogiri::TestCase

  def setup
    super
    @N = Nokogiri(File.read(HTML_FILE))
  end

  def assert_syntactical_equivalence(hpath, xpath, match, &blk)
    blk ||= lambda {|j| j.first}
    assert_equal match, blk.call(@N.search(xpath)), "xpath result did not match"
  end

  def test_child_tag
    assert_syntactical_equivalence("h1[a]", ".//h1[child::a]", "Tender Lovemaking") do |j|
      j.inner_text
    end
  end

  def test_child_tag_equals
    assert_syntactical_equivalence("h1[a='Tender Lovemaking']", ".//h1[child::a = 'Tender Lovemaking']", "Tender Lovemaking") do |j|
      j.inner_text
    end
  end

  def test_filter_contains
    assert_syntactical_equivalence("title:contains('Tender')", ".//title[contains(., 'Tender')]",
                                   "Tender Lovemaking  ") do |j|
      j.inner_text
    end
  end

  def test_filter_comment
    assert_syntactical_equivalence("div comment()[2]", ".//div//comment()[position() = 2]", "<!-- end of header -->") do |j|
      j.first.to_s
    end
  end

  def test_filter_text
    assert_syntactical_equivalence("a[text()]", ".//a[normalize-space(child::text())]", "<a href=\"http://tenderlovemaking.com\">Tender Lovemaking</a>") do |j|
      j.first.to_s
    end
    assert_syntactical_equivalence("a[text()='Tender Lovemaking']", ".//a[normalize-space(child::text()) = 'Tender Lovemaking']", "<a href=\"http://tenderlovemaking.com\">Tender Lovemaking</a>") do |j|
      j.first.to_s
    end
    assert_syntactical_equivalence("a/text()", ".//a/child::text()", "Tender Lovemaking") do |j|
      j.first.to_s
    end
    assert_syntactical_equivalence("h2//a[text()!='Back Home!']", ".//h2//a[normalize-space(child::text()) != 'Back Home!']", "Meow meow meow meow meow") do |j|
      j.first.inner_text
    end
  end

  def test_filter_by_attr
    assert_syntactical_equivalence("a[@href='http://blog.geminigeek.com/wordpress-theme']",
                                   ".//a[@href = 'http://blog.geminigeek.com/wordpress-theme']",
                                   "http://blog.geminigeek.com/wordpress-theme") do |j|
      j.first["href"]
    end
  end

  def test_css_id
    assert_syntactical_equivalence("#linkcat-7", ".//*[@id = 'linkcat-7']", "linkcat-7") do |j|
      j.first["id"]
    end
    assert_syntactical_equivalence("li#linkcat-7", ".//li[@id = 'linkcat-7']", "linkcat-7") do |j|
      j.first["id"]
    end
  end

  def test_css_class
    assert_syntactical_equivalence(".cat-item-15", ".//*[contains(concat(' ', @class, ' '), ' cat-item-15 ')]",
                                   "cat-item cat-item-15") do |j|
      j.first["class"]
    end
    assert_syntactical_equivalence("li.cat-item-15", ".//li[contains(concat(' ', @class, ' '), ' cat-item-15 ')]",
                                   "cat-item cat-item-15") do |j|
      j.first["class"]
    end
  end

  def test_css_tags
    assert_syntactical_equivalence("div li a", ".//div//li//a", "http://brobinius.org/") do |j|
      j.first.inner_text
    end
    assert_syntactical_equivalence("div li > a", ".//div//li/a", "http://brobinius.org/") do |j|
      j.first.inner_text
    end
    assert_syntactical_equivalence("h1 ~ small", ".//small[preceding-sibling::h1]", "The act of making love, tenderly.") do |j|
      j.first.inner_text
    end
    assert_syntactical_equivalence("h1 ~ small", ".//small[preceding-sibling::h1]", "The act of making love, tenderly.") do |j|
      j.first.inner_text
    end
  end

  def test_positional
    assert_syntactical_equivalence("div/div:first()", ".//div/div[position() = 1]", "\r\nTender Lovemaking\r\nThe act of making love, tenderly.\r\n".gsub(/[\r\n]/, '')) do |j|
      j.first.inner_text.gsub(/[\r\n]/, '')
    end
    assert_syntactical_equivalence("div/div:first", ".//div/div[position() = 1]", "\r\nTender Lovemaking\r\nThe act of making love, tenderly.\r\n".gsub(/[\r\n]/, '')) do |j|
      j.first.inner_text.gsub(/[\r\n]/, '')
    end
    assert_syntactical_equivalence("div//a:last()", ".//div//a[position() = last()]", "Wordpress") do |j|
      j.last.inner_text
    end
    assert_syntactical_equivalence("div//a:last", ".//div//a[position() = last()]", "Wordpress") do |j|
      j.last.inner_text
    end
  end

  def test_multiple_filters
    assert_syntactical_equivalence("a[@rel='bookmark'][1]", ".//a[@rel = 'bookmark' and position() = 1]", "Back Home!") do |j|
      j.first.inner_text
    end
  end

# TODO:
#       doc/'title ~ link' -> links that are siblings of title
#       doc/'p[@class~="final"]' -> class includes string (whitespacy)
#       doc/'p[text()*="final"]' -> class includes string (index) (broken: always returns true?)
#       doc/'p[text()$="final"]' -> /final$/
#       doc/'p[text()|="final"]' -> /^final$/
#       doc/'p[text()^="final"]' -> string starts with 'final
#       nth_first
#       nth_last
#       even
#       odd
#       first-child, nth-child, last-child, nth-last-child, nth-last-of-type
#       only-of-type, only-child
#       parent
#       empty
#       root
end
