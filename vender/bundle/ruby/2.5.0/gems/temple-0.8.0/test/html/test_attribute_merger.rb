require 'helper'

describe Temple::HTML::AttributeMerger do
  before do
    @merger = Temple::HTML::AttributeMerger.new
  end

  it 'should pass static attributes through' do
    @merger.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'class', [:static, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                     [:html, :attrs,
                      [:html, :attr, "class", [:static, "b"]]],
                     [:content]]
  end

  it 'should preserve the order of html attributes' do
    @merger.call([:html, :tag,
      'meta',
      [:html, :attrs, [:html, :attr, 'c', [:static, '1']],
                      [:html, :attr, 'd', [:static, '2']],
                      [:html, :attr, 'a', [:static, '3']],
                      [:html, :attr, 'b', [:static, '4']]]
    ]).should.equal [:html, :tag, 'meta',
                     [:html, :attrs,
                      [:html, :attr, 'c', [:static, '1']],
                      [:html, :attr, 'd', [:static, '2']],
                      [:html, :attr, 'a', [:static, '3']],
                      [:html, :attr, 'b', [:static, '4']]]]

    # Use case:
    @merger.call([:html, :tag,
      'meta',
      [:html, :attrs, [:html, :attr, 'http-equiv', [:static, 'Content-Type']],
                      [:html, :attr, 'content', [:static, '']]]
    ]).should.equal [:html, :tag, 'meta',
                     [:html, :attrs,
                      [:html, :attr, 'http-equiv', [:static, 'Content-Type']],
                      [:html, :attr, 'content', [:static, '']]]]
  end

  it 'should merge ids' do
    @merger.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'id', [:dynamic, 'a']], [:html, :attr, 'id', [:dynamic, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                     [:html, :attrs,
                      [:html, :attr, "id",
                       [:multi,
                        [:code, "_temple_html_attributemerger1 = []"],
                        [:capture, "_temple_html_attributemerger1[0]", [:dynamic, "a"]],
                        [:capture, "_temple_html_attributemerger1[1]", [:dynamic, "b"]],
                        [:dynamic, "_temple_html_attributemerger1.reject(&:empty?).join(\"_\")"]]]],
                     [:content]]
  end

  it 'should merge classes' do
    @merger.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'class', [:static, 'a']], [:html, :attr, 'class', [:dynamic, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                     [:html, :attrs,
                      [:html, :attr, "class",
                       [:multi,
                        [:code, "_temple_html_attributemerger1 = []"],
                        [:capture, "_temple_html_attributemerger1[0]", [:static, "a"]],
                        [:capture, "_temple_html_attributemerger1[1]", [:dynamic, "b"]],
                        [:dynamic, "_temple_html_attributemerger1.reject(&:empty?).join(\" \")"]]]],
                     [:content]]
  end
end

