require 'spec_helper'

describe Paperclip::Validators::AttachmentSizeValidator do
  before do
    rebuild_model
    @dummy = Dummy.new
  end

  def build_validator(options)
    @validator = Paperclip::Validators::AttachmentSizeValidator.new(options.merge(
      attributes: :avatar
    ))
  end

  def self.should_allow_attachment_file_size(size)
    context "when the attachment size is #{size}" do
      it "adds error to dummy object" do
        @dummy.stubs(:avatar_file_size).returns(size)
        @validator.validate(@dummy)
        assert @dummy.errors[:avatar_file_size].blank?,
          "Expect an error message on :avatar_file_size, got none."
      end

      it "does not add error to the base dummy object" do
        assert @dummy.errors[:avatar].blank?,
          "Error added to base attribute"
      end
    end
  end

  def self.should_not_allow_attachment_file_size(size, options = {})
    context "when the attachment size is #{size}" do
      before do
        @dummy.stubs(:avatar_file_size).returns(size)
        @validator.validate(@dummy)
      end

      it "adds error to dummy object" do
        assert @dummy.errors[:avatar_file_size].present?,
          "Unexpected error message on :avatar_file_size"
      end

      it "adds error to the base dummy object" do
        assert @dummy.errors[:avatar].present?,
          "Error not added to base attribute"
      end

      it "adds error to base object as a string" do
        expect(@dummy.errors[:avatar].first).to be_a String
      end

      if options[:message]
        it "returns a correct error message" do
          expect(@dummy.errors[:avatar_file_size]).to include options[:message]
        end
      end
    end
  end

  context "with :in option" do
    context "as a range" do
      before do
        build_validator in: (5.kilobytes..10.kilobytes)
      end

      should_allow_attachment_file_size(7.kilobytes)
      should_not_allow_attachment_file_size(4.kilobytes)
      should_not_allow_attachment_file_size(11.kilobytes)
    end

    context "as a proc" do
      before do
        build_validator in: lambda { |avatar| (5.kilobytes..10.kilobytes) }
      end

      should_allow_attachment_file_size(7.kilobytes)
      should_not_allow_attachment_file_size(4.kilobytes)
      should_not_allow_attachment_file_size(11.kilobytes)
    end
  end

  context "with :greater_than option" do
    context "as number" do
      before do
        build_validator greater_than: 10.kilobytes
      end

      should_allow_attachment_file_size 11.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end

    context "as a proc" do
      before do
        build_validator greater_than: lambda { |avatar| 10.kilobytes }
      end

      should_allow_attachment_file_size 11.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end
  end

  context "with :less_than option" do
    context "as number" do
      before do
        build_validator less_than: 10.kilobytes
      end

      should_allow_attachment_file_size 9.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end

    context "as a proc" do
      before do
        build_validator less_than: lambda { |avatar| 10.kilobytes }
      end

      should_allow_attachment_file_size 9.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end
  end

  context "with :greater_than and :less_than option" do
    context "as numbers" do
      before do
        build_validator greater_than: 5.kilobytes,
          less_than: 10.kilobytes
      end

      should_allow_attachment_file_size 7.kilobytes
      should_not_allow_attachment_file_size 5.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end

    context "as a proc" do
      before do
        build_validator greater_than: lambda { |avatar| 5.kilobytes },
          less_than: lambda { |avatar| 10.kilobytes }
      end

      should_allow_attachment_file_size 7.kilobytes
      should_not_allow_attachment_file_size 5.kilobytes
      should_not_allow_attachment_file_size 10.kilobytes
    end
  end

  context "with :message option" do
    context "given a range" do
      before do
        build_validator in: (5.kilobytes..10.kilobytes),
          message: "is invalid. (Between %{min} and %{max} please.)"
      end

      should_not_allow_attachment_file_size(
        11.kilobytes,
        message: "is invalid. (Between 5 KB and 10 KB please.)"
      )
    end

    context "given :less_than and :greater_than" do
      before do
        build_validator less_than: 10.kilobytes,
          greater_than: 5.kilobytes,
          message: "is invalid. (Between %{min} and %{max} please.)"
      end

      should_not_allow_attachment_file_size(
        11.kilobytes,
        message: "is invalid. (Between 5 KB and 10 KB please.)"
      )
    end
  end

  context "default error messages" do
    context "given :less_than and :greater_than" do
      before do
        build_validator greater_than: 5.kilobytes,
          less_than: 10.kilobytes
      end

      should_not_allow_attachment_file_size(
        11.kilobytes,
        message: "must be less than 10 KB"
      )

      should_not_allow_attachment_file_size(
        4.kilobytes,
        message: "must be greater than 5 KB"
      )
    end

    context "given a size range" do
      before do
        build_validator in: (5.kilobytes..10.kilobytes)
      end

      should_not_allow_attachment_file_size(
        11.kilobytes,
        message: "must be in between 5 KB and 10 KB"
      )

      should_not_allow_attachment_file_size(
        4.kilobytes,
        message: "must be in between 5 KB and 10 KB"
      )
    end
  end

  context "using the helper" do
    before do
      Dummy.validates_attachment_size :avatar, in: (5.kilobytes..10.kilobytes)
    end

    it "adds the validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_size }
    end
  end

  context "given options" do
    it "raises argument error if no required argument was given" do
      assert_raises(ArgumentError) do
        build_validator message: "Some message"
      end
    end

    (Paperclip::Validators::AttachmentSizeValidator::AVAILABLE_CHECKS).each do |argument|
      it "does not raise arguemnt error if #{argument} was given" do
        build_validator argument => 5.kilobytes
      end
    end

    it "does not raise argument error if :in was given" do
      build_validator in: (5.kilobytes..10.kilobytes)
    end
  end
end
