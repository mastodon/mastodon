require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#eql?" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).eql?(Hamster.interval(0, STACK_OVERFLOW_DEPTH)) }.should_not raise_error
      end
    end
  end

  shared_examples 'equal using eql?' do |a, b|
    specify "#{a.inspect} should eql? #{b.inspect}" do
      expect(a).to eql b
    end

    specify "#{a.inspect} should == #{b.inspect}" do
      expect(a).to eq b
    end
  end

  shared_examples 'not equal using eql?' do |a, b|
    specify "#{a.inspect} should not eql? #{b.inspect}" do
      expect(a).to_not eql b
    end
  end

  shared_examples 'equal using ==' do |a, b|
    specify "#{a.inspect} should == #{b.inspect}" do
      expect(a).to eq b
    end
  end

  shared_examples 'not equal using ==' do |a, b|
    specify "#{a.inspect} should not == #{b.inspect}" do
      expect(a).to_not eq b
    end
  end

  include_examples 'equal using =='       , L["A", "B", "C"], %w[A B C]
  include_examples 'not equal using eql?' , L["A", "B", "C"], %w[A B C]
  include_examples 'not equal using =='   , L["A", "B", "C"], Object.new
  include_examples 'not equal using eql?' , L["A", "B", "C"], Object.new
  include_examples 'equal using =='       , L.empty, []
  include_examples 'not equal using eql?' , L.empty, []

  include_examples 'equal using eql?'     , L.empty, L.empty
  include_examples 'not equal using eql?' , L.empty, L[nil]
  include_examples 'not equal using eql?' , L["A"], L.empty
  include_examples 'equal using eql?'     , L["A"], L["A"]
  include_examples 'not equal using eql?' , L["A"], L["B"]
  include_examples 'not equal using eql?' , L["A", "B"], L["A"]
  include_examples 'equal using eql?'     , L["A", "B", "C"], L["A", "B", "C"]
  include_examples 'not equal using eql?' , L["C", "A", "B"], L["A", "B", "C"]

  include_examples 'equal using =='       , L['A'], ['A']
  include_examples 'equal using =='       , ['A'], L['A']

  include_examples 'not equal using eql?' , L['A'], ['A']
  include_examples 'not equal using eql?' , ['A'], L['A']
end