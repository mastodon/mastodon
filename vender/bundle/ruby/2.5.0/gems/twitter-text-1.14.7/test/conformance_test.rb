require 'multi_json'
require 'nokogiri'
require 'test/unit'
require 'yaml'

# Detect Ruby 1.8 and older to apply necessary encoding fixes
major, minor, patch = RUBY_VERSION.split('.')
OLD_RUBY = major.to_i == 1 && minor.to_i < 9

if OLD_RUBY
  $KCODE='u'
end

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'twitter-text'

class ConformanceTest < Test::Unit::TestCase
  include Twitter::Extractor
  include Twitter::Autolink
  include Twitter::HitHighlighter
  include Twitter::Validation

  private

  %w(description expected json hits).each do |key|
    define_method key.to_sym do
      @test_info[key]
    end
  end

  if OLD_RUBY
    def text
      @test_info['text'].gsub(/\\u([0-9a-f]{8})/i) do
        [$1.to_i(16)].pack('U*')
      end
    end
  else
    def text
      @test_info['text']
    end
  end

  def assert_equal_without_attribute_order(expected, actual, failure_message = nil)
    assert_block(build_message(failure_message, "<?> expected but was\n<?>", expected, actual)) do
      equal_nodes?(Nokogiri::HTML(expected).root, Nokogiri::HTML(actual).root)
    end
  end

  def equal_nodes?(expected, actual)
    return false unless expected.name == actual.name
    return false unless ordered_attributes(expected) == ordered_attributes(actual)
    return false if expected.text? && actual.text? && expected.content != actual.content

    expected.children.each_with_index do |child, index|
      return false unless equal_nodes?(child, actual.children[index])
    end

    true
  end

  def ordered_attributes(element)
    element.attribute_nodes.map{|attr| [attr.name, attr.value]}.sort
  end

  CONFORMANCE_DIR = ENV['CONFORMANCE_DIR'] || File.expand_path("../../../conformance", __FILE__)

  def self.def_conformance_test(file, test_type, &block)
    yaml = YAML.load_file(File.join(CONFORMANCE_DIR, file))
    raise  "No such test suite: #{test_type.to_s}" unless yaml["tests"][test_type.to_s]

    file_name = file.split('.').first

    yaml["tests"][test_type.to_s].each do |test_info|
      name = :"test_#{file_name}_#{test_type} #{test_info['description']}"
      define_method name do
        @test_info = test_info
        instance_eval(&block)
      end
    end
  end

  public

  # Extractor Conformance
  def_conformance_test("extract.yml", :replies) do
    assert_equal expected, extract_reply_screen_name(text), description
  end

  def_conformance_test("extract.yml", :mentions) do
    assert_equal expected, extract_mentioned_screen_names(text), description
  end

  def_conformance_test("extract.yml", :mentions_with_indices) do
    e = expected.map{|elem| elem.inject({}){|h, (k,v)| h[k.to_sym] = v; h} }
    assert_equal e, extract_mentioned_screen_names_with_indices(text), description
  end

  def_conformance_test("extract.yml", :mentions_or_lists_with_indices) do
    e = expected.map{|elem| elem.inject({}){|h, (k,v)| h[k.to_sym] = v; h} }
    assert_equal e, extract_mentions_or_lists_with_indices(text), description
  end

  def_conformance_test("extract.yml", :urls) do
    assert_equal expected, extract_urls(text), description
    expected.each do |expected_url|
      assert_equal true, valid_url?(expected_url, true, false), "expected url [#{expected_url}] not valid"
    end
  end

  def_conformance_test("tlds.yml", :generic) do
    assert_equal expected, extract_urls(text), description
  end

  def_conformance_test("tlds.yml", :country) do
    assert_equal expected, extract_urls(text), description
  end

  def_conformance_test("extract.yml", :urls_with_indices) do
    e = expected.map{|elem| elem.inject({}){|h, (k,v)| h[k.to_sym] = v; h} }
    assert_equal e, extract_urls_with_indices(text), description
  end

  def_conformance_test("extract.yml", :hashtags) do
    assert_equal expected, extract_hashtags(text), description
  end

  def_conformance_test("extract.yml", :hashtags_from_astral) do
    assert_equal expected, extract_hashtags(text), description
  end

  def_conformance_test("extract.yml", :hashtags_with_indices) do
    e = expected.map{|elem| elem.inject({}){|h, (k,v)| h[k.to_sym] = v; h} }
    assert_equal e, extract_hashtags_with_indices(text), description
  end

  def_conformance_test("extract.yml", :cashtags) do
    assert_equal expected, extract_cashtags(text), description
  end

  def_conformance_test("extract.yml", :cashtags_with_indices) do
    e = expected.map{|elem| elem.inject({}){|h, (k,v)| h[k.to_sym] = v; h} }
    assert_equal e, extract_cashtags_with_indices(text), description
  end

  # Autolink Conformance
  def_conformance_test("autolink.yml", :usernames) do
    assert_equal_without_attribute_order expected, auto_link_usernames_or_lists(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :lists) do
    assert_equal_without_attribute_order expected, auto_link_usernames_or_lists(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :urls) do
    assert_equal_without_attribute_order expected, auto_link_urls(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :hashtags) do
    assert_equal_without_attribute_order expected, auto_link_hashtags(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :cashtags) do
    assert_equal_without_attribute_order expected, auto_link_cashtags(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :all) do
    assert_equal_without_attribute_order expected, auto_link(text, :suppress_no_follow => true), description
  end

  def_conformance_test("autolink.yml", :json) do
    assert_equal_without_attribute_order expected, auto_link_with_json(text, MultiJson.load(json), :suppress_no_follow => true), description
  end

  # HitHighlighter Conformance
  def_conformance_test("hit_highlighting.yml", :plain_text) do
    assert_equal expected, hit_highlight(text, hits), description
  end

  def_conformance_test("hit_highlighting.yml", :with_links) do
    assert_equal expected, hit_highlight(text, hits), description
  end

  # Validation Conformance
  def_conformance_test("validate.yml", :tweets) do
    assert_equal expected, valid_tweet_text?(text), description
  end

  def_conformance_test("validate.yml", :usernames) do
    assert_equal expected, valid_username?(text), description
  end

  def_conformance_test("validate.yml", :lists) do
    assert_equal expected, valid_list?(text), description
  end

  def_conformance_test("validate.yml", :urls) do
    assert_equal expected, valid_url?(text), description
  end

  def_conformance_test("validate.yml", :urls_without_protocol) do
    assert_equal expected, valid_url?(text, true, false), description
  end

  def_conformance_test("validate.yml", :hashtags) do
    assert_equal expected, valid_hashtag?(text), description
  end

  def_conformance_test("validate.yml", :lengths) do
    assert_equal expected, tweet_length(text), description
  end
end
