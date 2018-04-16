require 'spec_helper'

describe OrmAdapter::Base do
  subject { OrmAdapter::Base.new(Object) }

  describe "#extract_conditions!" do
    let(:conditions) { {:foo => 'bar'} }
    let(:order) { [[:foo, :asc]] }
    let(:limit) { 1 }
    let(:offset) { 2 }

    it "(<conditions>)" do
      subject.send(:extract_conditions!, conditions).should == [conditions, [], nil, nil]
    end

    it "(:conditions => <conditions>)" do
      subject.send(:extract_conditions!, :conditions => conditions).should == [conditions, [], nil, nil]
    end

    it "(:order => <order>)" do
      subject.send(:extract_conditions!, :order => order).should == [{}, order, nil, nil]
    end

    it "(:limit => <limit>)" do
      subject.send(:extract_conditions!, :limit => limit).should == [{}, [], limit, nil]
    end

    it "(:offset => <offset>)" do
      subject.send(:extract_conditions!, :offset => offset).should == [{}, [], nil, offset]
    end

    it "(:conditions => <conditions>, :order => <order>)" do
      subject.send(:extract_conditions!, :conditions => conditions, :order => order).should == [conditions, order, nil, nil]
    end

    it "(:conditions => <conditions>, :limit => <limit>)" do
      subject.send(:extract_conditions!, :conditions => conditions, :limit => limit).should == [conditions, [], limit, nil]
    end

    it "(:conditions => <conditions>, :offset => <offset>)" do
      subject.send(:extract_conditions!, :conditions => conditions, :offset => offset).should == [conditions, [], nil, offset]
    end

    describe "#valid_object?" do
      it "determines whether an object is valid for the current model class" do
        subject.send(:valid_object?, Object.new).should be_true
        subject.send(:valid_object?, String.new).should be_false
      end
    end

    describe "#normalize_order" do
      specify "(nil) returns []" do
        subject.send(:normalize_order, nil).should == []
      end

      specify ":foo returns [[:foo, :asc]]" do
        subject.send(:normalize_order, :foo).should == [[:foo, :asc]]
      end

      specify "[:foo] returns [[:foo, :asc]]" do
        subject.send(:normalize_order, [:foo]).should == [[:foo, :asc]]
      end

      specify "[:foo, :desc] returns [[:foo, :desc]]" do
        subject.send(:normalize_order, [:foo, :desc]).should == [[:foo, :desc]]
      end

      specify "[:foo, [:bar, :asc], [:baz, :desc], :bing] returns [[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]]" do
        subject.send(:normalize_order, [:foo, [:bar, :asc], [:baz, :desc], :bing]).should == [[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]]
      end

      specify "[[:foo, :wtf]] raises ArgumentError" do
        lambda { subject.send(:normalize_order, [[:foo, :wtf]]) }.should raise_error(ArgumentError)
      end

      specify "[[:foo, :asc, :desc]] raises ArgumentError" do
        lambda { subject.send(:normalize_order, [[:foo, :asc, :desc]]) }.should raise_error(ArgumentError)
      end
    end
  end
end
