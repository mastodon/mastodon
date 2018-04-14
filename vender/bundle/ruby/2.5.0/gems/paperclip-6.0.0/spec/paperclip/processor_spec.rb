require 'spec_helper'

describe Paperclip::Processor do
  it "instantiates and call #make when sent #make to the class" do
    processor = mock
    processor.expects(:make).with()
    Paperclip::Processor.expects(:new).with(:one, :two, :three).returns(processor)
    Paperclip::Processor.make(:one, :two, :three)
  end

  context "Calling #convert" do
    it "runs the convert command with Terrapin" do
      Paperclip.options[:log_command] = false
      Terrapin::CommandLine.expects(:new).with("convert", "stuff", {}).returns(stub(:run))
      Paperclip::Processor.new('filename').convert("stuff")
    end
  end

  context "Calling #identify" do
    it "runs the identify command with Terrapin" do
      Paperclip.options[:log_command] = false
      Terrapin::CommandLine.expects(:new).with("identify", "stuff", {}).returns(stub(:run))
      Paperclip::Processor.new('filename').identify("stuff")
    end
  end
end
