require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [
    [[], :car, nil],
    [["A"], :car, "A"],
    [%w[A B C], :car, "A"],
    [%w[A B C], :cadr, "B"],
    [%w[A B C], :caddr, "C"],
    [%w[A B C], :cadddr, nil],
    [%w[A B C], :caddddr, nil],
    [[], :cdr, L.empty],
    [["A"], :cdr, L.empty],
    [%w[A B C], :cdr, L["B", "C"]],
    [%w[A B C], :cddr, L["C"]],
    [%w[A B C], :cdddr, L.empty],
    [%w[A B C], :cddddr, L.empty],
  ].each do |values, method, expected|
    describe "##{method}" do
      it "is responded to" do
        L.empty.respond_to?(method).should == true
      end

      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.send(method)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.send(method).should == expected
        end
      end
    end
  end
end