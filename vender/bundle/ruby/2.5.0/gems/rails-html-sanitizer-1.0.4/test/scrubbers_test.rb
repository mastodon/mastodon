require "minitest/autorun"
require "rails-html-sanitizer"

class ScrubberTest < Minitest::Test
  protected

    def assert_scrubbed(html, expected = html)
      output = Loofah.scrub_fragment(html, @scrubber).to_s
      assert_equal expected, output
    end

    def to_node(text)
      Loofah.fragment(text).children.first
    end

    def assert_node_skipped(text)
      assert_scrub_returns(Loofah::Scrubber::CONTINUE, text)
    end

    def assert_scrub_stopped(text)
      assert_scrub_returns(Loofah::Scrubber::STOP, text)
    end

    def assert_scrub_returns(return_value, text)
      node = to_node(text)
      assert_equal return_value, @scrubber.scrub(node)
    end
end

class PermitScrubberTest < ScrubberTest

  def setup
    @scrubber = Rails::Html::PermitScrubber.new
  end

  def test_responds_to_scrub
    assert @scrubber.respond_to?(:scrub)
  end

  def test_default_scrub_behavior
    assert_scrubbed '<tag>hello</tag>', 'hello'
  end

  def test_default_attributes_removal_behavior
    assert_scrubbed '<p cooler="hello">hello</p>', '<p>hello</p>'
  end

  def test_leaves_supplied_tags
    @scrubber.tags = %w(a)
    assert_scrubbed '<a>hello</a>'
  end

  def test_leaves_only_supplied_tags
    html = '<tag>leave me <span>now</span></tag>'
    @scrubber.tags = %w(tag)
    assert_scrubbed html, '<tag>leave me now</tag>'
  end

  def test_leaves_only_supplied_tags_nested
    html = '<tag>leave <em>me <span>now</span></em></tag>'
    @scrubber.tags = %w(tag)
    assert_scrubbed html, '<tag>leave me now</tag>'
  end

  def test_leaves_supplied_attributes
    @scrubber.attributes = %w(cooler)
    assert_scrubbed '<a cooler="hello"></a>'
  end

  def test_leaves_only_supplied_attributes
    @scrubber.attributes = %w(cooler)
    assert_scrubbed '<a cooler="hello" b="c" d="e"></a>', '<a cooler="hello"></a>'
  end

  def test_leaves_supplied_tags_and_attributes
    @scrubber.tags = %w(tag)
    @scrubber.attributes = %w(cooler)
    assert_scrubbed '<tag cooler="hello"></tag>'
  end

  def test_leaves_only_supplied_tags_and_attributes
    @scrubber.tags = %w(tag)
    @scrubber.attributes = %w(cooler)
    html = '<a></a><tag href=""></tag><tag cooler=""></tag>'
    assert_scrubbed html, '<tag></tag><tag cooler=""></tag>'
  end

  def test_leaves_text
    assert_scrubbed('some text')
  end

  def test_skips_text_nodes
    assert_node_skipped('some text')
  end

  def test_tags_accessor_validation
    e = assert_raises(ArgumentError) do
      @scrubber.tags = 'tag'
    end

    assert_equal "You should pass :tags as an Enumerable", e.message
    assert_nil @scrubber.tags, "Tags should be nil when validation fails"
  end

  def test_attributes_accessor_validation
    e = assert_raises(ArgumentError) do
      @scrubber.attributes = 'cooler'
    end

    assert_equal "You should pass :attributes as an Enumerable", e.message
    assert_nil @scrubber.attributes, "Attributes should be nil when validation fails"
  end
end

class TargetScrubberTest < ScrubberTest
  def setup
    @scrubber = Rails::Html::TargetScrubber.new
  end

  def test_targeting_tags_removes_only_them
    @scrubber.tags = %w(a h1)
    html = '<script></script><a></a><h1></h1>'
    assert_scrubbed html, '<script></script>'
  end

  def test_targeting_tags_removes_only_them_nested
    @scrubber.tags = %w(a)
    html = '<tag><a><tag><a></a></tag></a></tag>'
    assert_scrubbed html, '<tag><tag></tag></tag>'
  end

  def test_targeting_attributes_removes_only_them
    @scrubber.attributes = %w(class id)
    html = '<a class="a" id="b" onclick="c"></a>'
    assert_scrubbed html, '<a onclick="c"></a>'
  end

  def test_targeting_tags_and_attributes_removes_only_them
    @scrubber.tags = %w(tag)
    @scrubber.attributes = %w(remove)
    html = '<tag remove="" other=""></tag><a remove="" other=""></a>'
    assert_scrubbed html, '<a other=""></a>'
  end
end

class TextOnlyScrubberTest < ScrubberTest
  def setup
    @scrubber = Rails::Html::TextOnlyScrubber.new
  end

  def test_removes_all_tags_and_keep_the_content
    assert_scrubbed '<tag>hello</tag>', 'hello'
  end

  def test_skips_text_nodes
    assert_node_skipped('some text')
  end
end

class ReturningStopFromScrubNodeTest < ScrubberTest
  class ScrubStopper < Rails::Html::PermitScrubber
    def scrub_node(node)
      Loofah::Scrubber::STOP
    end
  end

  def setup
    @scrubber = ScrubStopper.new
  end

  def test_returns_stop_from_scrub_if_scrub_node_does
    assert_scrub_stopped '<script>remove me</script>'
  end
end
