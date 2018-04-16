require 'spec_helper'

describe Paperclip::TempfileFactory do
  it "is able to generate a tempfile with the right name" do
    file = subject.generate("omg.png")
    assert File.extname(file.path), "png"
  end

  it "is able to generate a tempfile with the right name with a tilde at the beginning" do
    file = subject.generate("~omg.png")
    assert File.extname(file.path), "png"
  end

  it "is able to generate a tempfile with the right name with a tilde at the end" do
    file = subject.generate("omg.png~")
    assert File.extname(file.path), "png"
  end

  it "is able to generate a tempfile from a file with a really long name" do
    filename = "#{"longfilename" * 100}.png"
    file = subject.generate(filename)
    assert File.extname(file.path), "png"
  end

  it 'is able to take nothing as a parameter and not error' do
   file = subject.generate
   assert File.exist?(file.path)
  end

  it "does not throw Errno::ENAMETOOLONG when it has a really long name" do
    expect { subject.generate("o" * 255) }.to_not raise_error
  end
end
