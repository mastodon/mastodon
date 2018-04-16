require 'spec_helper'
require 'paperclip/matchers'

describe Paperclip::Shoulda::Matchers::ValidateAttachmentPresenceMatcher do
  extend Paperclip::Shoulda::Matchers

  before do
    reset_table("dummies") do |d|
      d.string :avatar_file_name
    end
    reset_class "Dummy"
    Dummy.has_attached_file :avatar
    Dummy.do_not_validate_attachment_file_type :avatar
  end

  it "rejects a class with no validation" do
    expect(matcher).to_not accept(Dummy)
  end

  it "accepts a class with a matching validation" do
    Dummy.validates_attachment_presence :avatar
    expect(matcher).to accept(Dummy)
  end

  it "accepts an instance with other attachment validations" do
    reset_table("dummies") do |d|
      d.string :avatar_file_name
      d.string :avatar_content_type
    end
    Dummy.class_eval do
      validates_attachment_presence :avatar
      validates_attachment_content_type :avatar, content_type: 'image/gif'
    end
    dummy = Dummy.new

    dummy.avatar = File.new fixture_file('5k.png')

    expect(matcher).to accept(dummy)
  end

  context "using an :if to control the validation" do
    before do
      Dummy.class_eval do
        validates_attachment_presence :avatar, if: :go
        attr_accessor :go
      end
    end

    it "runs the validation if the control is true" do
      dummy = Dummy.new
      dummy.avatar = nil
      dummy.go = true
      expect(matcher).to accept(dummy)
    end

    it "does not run the validation if the control is false" do
      dummy = Dummy.new
      dummy.avatar = nil
      dummy.go = false
      expect(matcher).to_not accept(dummy)
    end
  end

  private

  def matcher
    self.class.validate_attachment_presence(:avatar)
  end
end
