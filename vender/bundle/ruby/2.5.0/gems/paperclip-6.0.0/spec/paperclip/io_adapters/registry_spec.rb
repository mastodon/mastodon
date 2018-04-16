require 'spec_helper'

describe Paperclip::AttachmentRegistry do
  context "for" do
    before do
      class AdapterTest
        def initialize(_target, _ = {}); end
      end
      @subject = Paperclip::AdapterRegistry.new
      @subject.register(AdapterTest){|t| Symbol === t }
    end

    it "returns the class registered for the adapted type" do
      assert_equal AdapterTest, @subject.for(:target).class
    end
  end

  context "registered?" do
    before do
      class AdapterTest
        def initialize(_target, _ = {}); end
      end
      @subject = Paperclip::AdapterRegistry.new
      @subject.register(AdapterTest){|t| Symbol === t }
    end

    it "returns true when the class of this adapter has been registered" do
      assert @subject.registered?(AdapterTest.new(:target))
    end

    it "returns false when the adapter has not been registered" do
      assert ! @subject.registered?(Object)
    end
  end
end
