require 'helper'

describe Temple::Filters::Escapable do
  before do
    @filter = Temple::Filters::Escapable.new
  end

  it 'should handle escape expressions' do
    @filter.call([:escape, true,
                  [:multi,
                   [:static, "a < b"],
                   [:dynamic, "ruby_method"]]
    ]).should.equal [:multi,
      [:static, "a &lt; b"],
      [:dynamic, "::Temple::Utils.escape_html((ruby_method))"],
    ]
  end

  it 'should keep codes intact' do
    exp = [:multi, [:code, 'foo']]
    @filter.call(exp).should.equal exp
  end

  it 'should keep statics intact' do
    exp = [:multi, [:static, '<']]
    @filter.call(exp).should.equal exp
  end

  it 'should keep dynamic intact' do
    exp = [:multi, [:dynamic, 'foo']]
    @filter.call(exp).should.equal exp
  end

  it 'should have use_html_safe option' do
    with_html_safe do
      filter = Temple::Filters::Escapable.new(use_html_safe: true)
      filter.call([:escape, true,
        [:static, Temple::HTML::SafeString.new("a < b")]
      ]).should.equal [:static, "a < b"]
    end
  end

  it 'should support censoring' do
    filter = Temple::Filters::Escapable.new(escape_code: '(%s).gsub("Temple sucks", "Temple rocks")')
    filter.call([:escape, true,
      [:static, "~~ Temple sucks ~~"]
    ]).should.equal [:static, "~~ Temple rocks ~~"]
  end
end
