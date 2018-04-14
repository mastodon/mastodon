require 'spec_helper'

describe Paperclip::Validators::MediaTypeSpoofDetectionValidator do
  before do
    rebuild_model
    @dummy = Dummy.new
  end

  def build_validator(options = {})
    @validator = Paperclip::Validators::MediaTypeSpoofDetectionValidator.new(options.merge(
      attributes: :avatar
    ))
  end

  it "is on the attachment without being explicitly added" do
    assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :media_type_spoof_detection }
  end

  it "is not on the attachment when explicitly rejected" do
    rebuild_model validate_media_type: false
    assert Dummy.validators_on(:avatar).none?{ |validator| validator.kind == :media_type_spoof_detection }
  end

  it "returns default error message for spoofed media type" do
    build_validator
    file = File.new(fixture_file("5k.png"), "rb")
    @dummy.avatar.assign(file)

    detector = mock("detector", :spoofed? => true)
    Paperclip::MediaTypeSpoofDetector.stubs(:using).returns(detector)
    @validator.validate(@dummy)

    assert_equal I18n.t("errors.messages.spoofed_media_type"), @dummy.errors[:avatar].first
  end

  it "runs when attachment is dirty" do
    build_validator
    file = File.new(fixture_file("5k.png"), "rb")
    @dummy.avatar.assign(file)
    Paperclip::MediaTypeSpoofDetector.stubs(:using).returns(stub(:spoofed? => false))

    @dummy.valid?

    assert_received(Paperclip::MediaTypeSpoofDetector, :using){|e| e.once }
  end

  it "does not run when attachment is not dirty" do
    Paperclip::MediaTypeSpoofDetector.stubs(:using).never
    @dummy.valid?
    assert_received(Paperclip::MediaTypeSpoofDetector, :using){|e| e.never }
  end
end
