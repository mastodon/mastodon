require 'spec_helper'
require 'paperclip/matchers'

describe Paperclip::Shoulda::Matchers::ValidateAttachmentSizeMatcher do
  extend Paperclip::Shoulda::Matchers

  before do
    reset_table("dummies") do |d|
      d.string :avatar_file_name
      d.integer :avatar_file_size
    end
    reset_class "Dummy"
    Dummy.do_not_validate_attachment_file_type :avatar
    Dummy.has_attached_file :avatar
  end

  context "Limiting size" do
    it "rejects a class with no validation" do
      expect(matcher.in(256..1024)).to_not accept(Dummy)
    end

    it "rejects a class with a validation that's too high" do
      Dummy.validates_attachment_size :avatar, in: 256..2048
      expect(matcher.in(256..1024)).to_not accept(Dummy)
    end

    it "accepts a class with a validation that's too low" do
      Dummy.validates_attachment_size :avatar, in: 0..1024
      expect(matcher.in(256..1024)).to_not accept(Dummy)
    end

    it "accepts a class with a validation that matches" do
      Dummy.validates_attachment_size :avatar, in: 256..1024
      expect(matcher.in(256..1024)).to accept(Dummy)
    end
  end

  context "allowing anything" do
    it "given a class with an upper limit" do
      Dummy.validates_attachment_size :avatar, less_than: 1
      expect(matcher).to accept(Dummy)
    end

    it "given a class with a lower limit" do
      Dummy.validates_attachment_size :avatar, greater_than: 1
      expect(matcher).to accept(Dummy)
    end
  end

  context "using an :if to control the validation" do
    before do
      Dummy.class_eval do
        validates_attachment_size :avatar, greater_than: 1024, if: :go
        attr_accessor :go
      end
    end

    it "run the validation if the control is true" do
      dummy = Dummy.new
      dummy.go = true
      expect(matcher.greater_than(1024)).to accept(dummy)
    end

    it "not run the validation if the control is false" do
      dummy = Dummy.new
      dummy.go = false
      expect(matcher.greater_than(1024)).to_not accept(dummy)
    end
  end

  context "post processing" do
    before do
      Dummy.validates_attachment_size :avatar, greater_than: 1024
    end

    it "be skipped" do
      dummy = Dummy.new
      dummy.avatar.expects(:post_process).never
      expect(matcher.greater_than(1024)).to accept(dummy)
    end
  end

  private

  def matcher
    self.class.validate_attachment_size(:avatar)
  end
end
