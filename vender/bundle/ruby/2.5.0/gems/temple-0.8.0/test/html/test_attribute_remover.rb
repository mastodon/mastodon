require 'helper'

describe Temple::HTML::AttributeRemover do
  before do
    @remover = Temple::HTML::AttributeRemover.new
  end

  it 'should pass static attributes through' do
    @remover.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'class', [:static, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                     [:multi,
                      [:html, :attr, "class", [:static, "b"]]],
                     [:content]]
  end

  it 'should check for empty dynamic attribute if it is included in :remove_empty_attrs' do
    @remover.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'class', [:dynamic, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                    [:multi,
                      [:multi,
                       [:capture, "_temple_html_attributeremover1", [:dynamic, "b"]],
                       [:if, "!_temple_html_attributeremover1.empty?",
                        [:html, :attr, "class", [:dynamic, "_temple_html_attributeremover1"]]]]],
                     [:content]]
  end

  it 'should not check for empty dynamic attribute if it is not included in :remove_empty_attrs' do
    @remover.call([:html, :tag,
      'div',
      [:html, :attrs, [:html, :attr, 'name', [:dynamic, 'b']]],
      [:content]
    ]).should.equal [:html, :tag, "div",
                     [:multi,
                      [:html, :attr, "name", [:dynamic, "b"]]],
                     [:content]]
  end
end
