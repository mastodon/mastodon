require 'spec_helper'
require 'paperclip/matchers'

describe Paperclip::Shoulda::Matchers::ValidateAttachmentContentTypeMatcher do
  extend Paperclip::Shoulda::Matchers

  before do
    reset_table("dummies") do |d|
      d.string :title
      d.string :avatar_file_name
      d.string :avatar_content_type
    end
    reset_class "Dummy"
    Dummy.do_not_validate_attachment_file_type :avatar
    Dummy.has_attached_file :avatar
  end

  it "rejects a class with no validation" do
    expect(matcher).to_not accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it 'rejects a class when the validation fails' do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{audio/.*}
    expect(matcher).to_not accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "accepts a class with a matching validation" do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{image/.*}
    expect(matcher).to accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "accepts a class with other validations but matching types" do
    Dummy.validates_presence_of :title
    Dummy.validates_attachment_content_type :avatar, content_type: %r{image/.*}
    expect(matcher).to accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "accepts a class that matches and a matcher that only specifies 'allowing'" do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{image/.*}
    matcher = plain_matcher.allowing(%w(image/png image/jpeg))

    expect(matcher).to accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "rejects a class that does not match and a matcher that only specifies 'allowing'" do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{audio/.*}
    matcher = plain_matcher.allowing(%w(image/png image/jpeg))

    expect(matcher).to_not accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "accepts a class that matches and a matcher that only specifies 'rejecting'" do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{image/.*}
    matcher = plain_matcher.rejecting(%w(audio/mp3 application/octet-stream))

    expect(matcher).to accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  it "rejects a class that does not match and a matcher that only specifies 'rejecting'" do
    Dummy.validates_attachment_content_type :avatar, content_type: %r{audio/.*}
    matcher = plain_matcher.rejecting(%w(audio/mp3 application/octet-stream))

    expect(matcher).to_not accept(Dummy)
    expect { matcher.failure_message }.to_not raise_error
  end

  context "using an :if to control the validation" do
    before do
      Dummy.class_eval do
        validates_attachment_content_type :avatar, content_type: %r{image/*} , if: :go
        attr_accessor :go
      end
    end

    it "runs the validation if the control is true" do
      dummy = Dummy.new
      dummy.go = true
      expect(matcher).to accept(dummy)
      expect { matcher.failure_message }.to_not raise_error
    end

    it "does not run the validation if the control is false" do
      dummy = Dummy.new
      dummy.go = false
      expect(matcher).to_not accept(dummy)
      expect { matcher.failure_message }.to_not raise_error
    end
  end

  private

  def plain_matcher
    self.class.validate_attachment_content_type(:avatar)
  end

  def matcher
    plain_matcher.
      allowing(%w(image/png image/jpeg)).
      rejecting(%w(audio/mp3 application/octet-stream))
  end

end
