require 'spec_helper'

describe Paperclip::NilAdapter do
  context 'a new instance' do
    before do
      @subject = Paperclip.io_adapters.for(nil)
    end

    it "gets the right filename" do
      assert_equal "", @subject.original_filename
    end

    it "gets the content type" do
      assert_equal "", @subject.content_type
    end

    it "gets the file's size" do
      assert_equal 0, @subject.size
    end

    it "returns true for a call to nil?" do
      assert @subject.nil?
    end
  end
end
