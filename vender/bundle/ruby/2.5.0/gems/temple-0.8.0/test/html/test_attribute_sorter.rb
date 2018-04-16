require 'helper'

describe Temple::HTML::AttributeSorter do
  before do
    @ordered   = Temple::HTML::AttributeSorter.new
    @unordered = Temple::HTML::AttributeSorter.new sort_attrs: false
  end

  it 'should sort html attributes by name by default, when :sort_attrs is true' do
    @ordered.call([:html, :tag,
      'meta',
      [:html, :attrs, [:html, :attr, 'c', [:static, '1']],
                      [:html, :attr, 'd', [:static, '2']],
                      [:html, :attr, 'a', [:static, '3']],
                      [:html, :attr, 'b', [:static, '4']]]
    ]).should.equal [:html, :tag, 'meta',
                     [:html, :attrs,
                      [:html, :attr, 'a', [:static, '3']],
                      [:html, :attr, 'b', [:static, '4']],
                      [:html, :attr, 'c', [:static, '1']],
                      [:html, :attr, 'd', [:static, '2']]]]
  end

  it 'should preserve the order of html attributes when :sort_attrs is false' do
    @unordered.call([:html, :tag,
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
    @unordered.call([:html, :tag,
      'meta',
      [:html, :attrs, [:html, :attr, 'http-equiv', [:static, 'Content-Type']],
                      [:html, :attr, 'content', [:static, '']]]
    ]).should.equal [:html, :tag, 'meta',
                     [:html, :attrs,
                      [:html, :attr, 'http-equiv', [:static, 'Content-Type']],
                      [:html, :attr, 'content', [:static, '']]]]
  end
end
