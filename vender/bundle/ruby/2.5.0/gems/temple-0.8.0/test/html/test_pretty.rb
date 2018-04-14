require 'helper'

describe Temple::HTML::Pretty do
  before do
    @html = Temple::HTML::Pretty.new
  end

  it 'should indent nested tags' do
    @html.call([:html, :tag, 'div', [:multi],
      [:html, :tag, 'p', [:multi], [:multi, [:static, 'text'], [:dynamic, 'code']]]
    ]).should.equal [:multi,
                     [:code, "_temple_html_pretty1 = /<code|<pre|<textarea/"],
                     [:multi,
                      [:static, "<div"],
                      [:multi],
                      [:static, ">"],
                      [:multi,
                       [:static, "\n  <p"],
                       [:multi],
                       [:static, ">"],
                       [:multi,
                        [:static, "\n    text"],
                        [:dynamic, "::Temple::Utils.indent_dynamic((code), false, \"\\n    \", _temple_html_pretty1)"]],
                       [:static, "\n  </p>"]],
                      [:static, "\n</div>"]]]
  end

  it 'should not indent preformatted tags' do
    @html.call([:html, :tag, 'pre', [:multi],
      [:html, :tag, 'p', [:multi], [:static, 'text']]
    ]).should.equal [:multi,
                     [:code, "_temple_html_pretty1 = /<code|<pre|<textarea/"],
                     [:multi,
                      [:static, "<pre"],
                      [:multi],
                      [:static, ">"],
                      [:multi,
                       [:static, "<p"],
                       [:multi],
                       [:static, ">"],
                       [:static, "text"],
                       [:static, "</p>"]],
                      [:static, "</pre>"]]]
  end

  it 'should not escape html_safe strings' do
    with_html_safe do
      @html.call(
        [:dynamic, '"text<".html_safe']
      ).should.equal [:multi,
                      [:code, "_temple_html_pretty1 = /<code|<pre|<textarea/"],
                      [:dynamic, "::Temple::Utils.indent_dynamic((\"text<\".html_safe), nil, \"\\n\", _temple_html_pretty1)"]]
    end
  end
end
