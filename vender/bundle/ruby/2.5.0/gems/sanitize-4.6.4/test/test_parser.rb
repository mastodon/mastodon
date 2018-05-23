# encoding: utf-8
require_relative 'common'

describe 'Parser' do
  make_my_diffs_pretty!
  parallelize_me!

  it 'should translate valid entities into characters' do
    Sanitize.fragment("&apos;&eacute;&amp;").must_equal("'é&amp;")
  end

  it 'should translate orphaned ampersands into entities' do
    Sanitize.fragment('at&t').must_equal('at&amp;t')
  end

  it 'should not add newlines after tags when serializing a fragment' do
    Sanitize.fragment("<div>foo\n\n<p>bar</p><div>\nbaz</div></div><div>quux</div>", :elements => ['div', 'p'])
      .must_equal "<div>foo\n\n<p>bar</p><div>\nbaz</div></div><div>quux</div>"
  end

  it 'should not have the Nokogiri 1.4.2+ unterminated script/style element bug' do
    Sanitize.fragment('foo <script>bar').must_equal 'foo bar'
    Sanitize.fragment('foo <style>bar').must_equal 'foo bar'
  end

  it 'ambiguous non-tag brackets like "1 > 2 and 2 < 1" should be parsed correctly' do
    Sanitize.fragment('1 > 2 and 2 < 1').must_equal '1 &gt; 2 and 2 &lt; 1'
    Sanitize.fragment('OMG HAPPY BIRTHDAY! *<:-D').must_equal 'OMG HAPPY BIRTHDAY! *&lt;:-D'
  end

  # https://github.com/sparklemotion/nokogiri/issues/1008
  it 'should work around the libxml2 content-type meta tag bug' do
    Sanitize.document('<html><head></head><body>Howdy!</body></html>',
      :elements => %w[html head body]
    ).must_equal "<html><head></head><body>Howdy!</body></html>\n"

    Sanitize.document('<html><head></head><body>Howdy!</body></html>',
      :elements => %w[html head meta body]
    ).must_equal "<html><head></head><body>Howdy!</body></html>\n"

    Sanitize.document('<html><head><meta charset="utf-8"></head><body>Howdy!</body></html>',
      :elements   => %w[html head meta body],
      :attributes => {'meta' => ['charset']}
    ).must_equal "<html><head><meta charset=\"utf-8\"></head><body>Howdy!</body></html>\n"

    Sanitize.document('<html><head><meta http-equiv="Content-Type" content="text/html;charset=utf-8"></head><body>Howdy!</body></html>',
      :elements   => %w[html head meta body],
      :attributes => {'meta' => %w[charset content http-equiv]}
    ).must_equal "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\"></head><body>Howdy!</body></html>\n"

    # Edge case: an existing content-type meta tag with a non-UTF-8 content type
    # will be converted to UTF-8, since that's the only output encoding we
    # support.
    Sanitize.document('<html><head><meta http-equiv="content-type" content="text/html;charset=us-ascii"></head><body>Howdy!</body></html>',
      :elements   => %w[html head meta body],
      :attributes => {'meta' => %w[charset content http-equiv]}
    ).must_equal "<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"></head><body>Howdy!</body></html>\n"
  end

  describe 'when siblings are added after a node during traversal' do
    it 'the added siblings should be traversed' do
      html = %[
        <div id="one">
            <div id="one_one">
                <div id="one_one_one"></div>
            </div>
            <div id="one_two"></div>
        </div>
        <div id="two">
            <div id="two_one"><div id="two_one_one"></div></div>
            <div id="two_two"></div>
        </div>
        <div id="three"></div>
      ]

      siblings = []

      Sanitize.fragment(html, :transformers => ->(env) {
          name = env[:node].name

          if name == 'div'
            env[:node].add_next_sibling('<b id="added_' + env[:node]['id'] + '">')
          elsif name == 'b'
            siblings << env[:node][:id]
          end

          return {:node_whitelist => [env[:node]]}
      })

      # All siblings should be traversed, and in the order added.
      siblings.must_equal [
        "added_one_one_one",
        "added_one_one",
        "added_one_two",
        "added_one",
        "added_two_one_one",
        "added_two_one",
        "added_two_two",
        "added_two",
        "added_three"
      ]
    end
  end
end
