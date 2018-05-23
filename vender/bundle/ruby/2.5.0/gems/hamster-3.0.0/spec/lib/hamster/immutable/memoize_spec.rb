require "spec_helper"
require "hamster/immutable"

describe Hamster::Immutable do
  class Fixture
    include Hamster::Immutable

    def initialize(&block)
      @block = block
    end

    def call
      @block.call
    end
    memoize :call

    def copy
      transform {}
    end
  end

  let(:immutable) { Fixture.new { @count += 1 } }

  describe "#memoize" do
    before(:each) do
      @count = 0
      immutable.call
    end

    it "keeps the receiver frozen and immutable" do
      expect(immutable).to be_immutable
    end

    context "when called multiple times" do
      before(:each) do
        immutable.call
      end

      it "doesn't evaluate the memoized method more than once" do
        expect(@count).to eq(1)
      end
    end

    describe "when making a copy" do
      let(:copy) { immutable.copy }

      before(:each) do
        copy.call
      end

      it "clears all memory" do
        expect(@count).to eq(2)
      end
    end
  end
end
