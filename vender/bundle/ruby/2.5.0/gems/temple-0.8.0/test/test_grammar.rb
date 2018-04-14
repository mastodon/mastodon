require 'helper'

describe Temple::Grammar do
  it 'should match core expressions' do
    Temple::Grammar.should.match [:multi]
    Temple::Grammar.should.match [:multi, [:multi]]
    Temple::Grammar.should.match [:static, 'Text']
    Temple::Grammar.should.match [:dynamic, 'Text']
    Temple::Grammar.should.match [:code, 'Text']
    Temple::Grammar.should.match [:capture, 'Text', [:multi]]
    Temple::Grammar.should.match [:newline]
  end

  it 'should not match invalid core expressions' do
    Temple::Grammar.should.not.match [:multi, 'String']
    Temple::Grammar.should.not.match [:static]
    Temple::Grammar.should.not.match [:dynamic, 1]
    Temple::Grammar.should.not.match [:code, :sym]
    Temple::Grammar.should.not.match [:capture, [:multi]]
    Temple::Grammar.should.not.match [:newline, [:multi]]
  end

  it 'should match control flow expressions' do
    Temple::Grammar.should.match [:if, 'Condition', [:multi]]
    Temple::Grammar.should.match [:if, 'Condition', [:multi], [:multi]]
    Temple::Grammar.should.match [:block, 'Loop', [:multi]]
    Temple::Grammar.should.match [:case, 'Arg', ['Cond1', [:multi]], ['Cond1', [:multi]], [:else, [:multi]]]
    Temple::Grammar.should.not.match [:case, 'Arg', [:sym, [:multi]]]
    Temple::Grammar.should.match [:cond, ['Cond1', [:multi]], ['Cond2', [:multi]], [:else, [:multi]]]
    Temple::Grammar.should.not.match [:cond, [:sym, [:multi]]]
  end

  it 'should match escape expression' do
    Temple::Grammar.should.match [:escape, true, [:multi]]
    Temple::Grammar.should.match [:escape, false, [:multi]]
  end

  it 'should match html expressions' do
    Temple::Grammar.should.match [:html, :doctype, 'Doctype']
    Temple::Grammar.should.match [:html, :comment, [:multi]]
    Temple::Grammar.should.match [:html, :tag, 'Tag', [:multi]]
    Temple::Grammar.should.match [:html, :tag, 'Tag', [:multi], [:multi]]
    Temple::Grammar.should.match [:html, :tag, 'Tag', [:multi], [:static, 'Text']]
    Temple::Grammar.should.match [:html, :tag, 'Tag', [:html, :attrs, [:html, :attr, 'id',
                                  [:static, 'val']]], [:static, 'Text']]
  end
end
