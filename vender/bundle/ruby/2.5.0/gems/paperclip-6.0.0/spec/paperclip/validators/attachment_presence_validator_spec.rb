require 'spec_helper'

describe Paperclip::Validators::AttachmentPresenceValidator do
  before do
    rebuild_model
    @dummy = Dummy.new
  end

  def build_validator(options={})
    @validator = Paperclip::Validators::AttachmentPresenceValidator.new(options.merge(
      attributes: :avatar
    ))
  end

  context "nil attachment" do
    before do
      @dummy.avatar = nil
    end

    context "with default options" do
      before do
        build_validator
        @validator.validate(@dummy)
      end

      it "adds error on the attachment" do
        assert @dummy.errors[:avatar].present?
      end

      it "does not add an error on the file_name attribute" do
        assert @dummy.errors[:avatar_file_name].blank?
      end
    end

    context "with :if option" do
      context "returning true" do
        before do
          build_validator if: true
          @validator.validate(@dummy)
        end

        it "performs a validation" do
          assert @dummy.errors[:avatar].present?
        end
      end

      context "returning false" do
        before do
          build_validator if: false
          @validator.validate(@dummy)
        end

        it "performs a validation" do
          assert @dummy.errors[:avatar].present?
        end
      end
    end
  end

  context "with attachment" do
    before do
      build_validator
      @dummy.avatar = StringIO.new('.\n')
      @validator.validate(@dummy)
    end

    it "does not add error on the attachment" do
      assert @dummy.errors[:avatar].blank?
    end

    it "does not add an error on the file_name attribute" do
      assert @dummy.errors[:avatar_file_name].blank?
    end
  end

  context "using the helper" do
    before do
      Dummy.validates_attachment_presence :avatar
    end

    it "adds the validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_presence }
    end
  end
end
