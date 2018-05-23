require 'spec_helper'

describe Paperclip::Validators::AttachmentContentTypeValidator do
  before do
    rebuild_model
    @dummy = Dummy.new
  end

  def build_validator(options)
    @validator = Paperclip::Validators::AttachmentContentTypeValidator.new(options.merge(
      attributes: :avatar
    ))
  end

  context "with a nil content type" do
    before do
      build_validator content_type: "image/jpg"
      @dummy.stubs(avatar_content_type: nil)
      @validator.validate(@dummy)
    end

    it "does not set an error message" do
      assert @dummy.errors[:avatar_content_type].blank?
    end
  end

  context "with :allow_nil option" do
    context "as true" do
      before do
        build_validator content_type: "image/png", allow_nil: true
        @dummy.stubs(avatar_content_type: nil)
        @validator.validate(@dummy)
      end

      it "allows avatar_content_type as nil" do
        assert @dummy.errors[:avatar_content_type].blank?
      end
    end

    context "as false" do
      before do
        build_validator content_type: "image/png", allow_nil: false
        @dummy.stubs(avatar_content_type: nil)
        @validator.validate(@dummy)
      end

      it "does not allow avatar_content_type as nil" do
        assert @dummy.errors[:avatar_content_type].present?
      end
    end
  end

  context "with a failing validation" do
    before do
      build_validator content_type: "image/png", allow_nil: false
      @dummy.stubs(avatar_content_type: nil)
      @validator.validate(@dummy)
    end

    it "adds error to the base object" do
      assert @dummy.errors[:avatar].present?,
        "Error not added to base attribute"
    end

    it "adds error to base object as a string" do
      expect(@dummy.errors[:avatar].first).to be_a String
    end
  end

  context "with a successful validation" do
    before do
      build_validator content_type: "image/png", allow_nil: false
      @dummy.stubs(avatar_content_type: "image/png")
      @validator.validate(@dummy)
    end

    it "does not add error to the base object" do
      assert @dummy.errors[:avatar].blank?,
        "Error was added to base attribute"
    end
  end

  context "with :allow_blank option" do
    context "as true" do
      before do
        build_validator content_type: "image/png", allow_blank: true
        @dummy.stubs(avatar_content_type: "")
        @validator.validate(@dummy)
      end

      it "allows avatar_content_type as blank" do
        assert @dummy.errors[:avatar_content_type].blank?
      end
    end

    context "as false" do
      before do
        build_validator content_type: "image/png", allow_blank: false
        @dummy.stubs(avatar_content_type: "")
        @validator.validate(@dummy)
      end

      it "does not allow avatar_content_type as blank" do
        assert @dummy.errors[:avatar_content_type].present?
      end
    end
  end

  context "whitelist format" do
    context "with an allowed type" do
      context "as a string" do
        before do
          build_validator content_type: "image/jpg"
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end

      context "as an regexp" do
        before do
          build_validator content_type: /^image\/.*/
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end

      context "as a list" do
        before do
          build_validator content_type: ["image/png", "image/jpg", "image/jpeg"]
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end
    end

    context "with a disallowed type" do
      context "as a string" do
        before do
          build_validator content_type: "image/png"
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "sets a correct default error message" do
          assert @dummy.errors[:avatar_content_type].present?
          expect(@dummy.errors[:avatar_content_type]).to include "is invalid"
        end
      end

      context "as a regexp" do
        before do
          build_validator content_type: /^text\/.*/
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "sets a correct default error message" do
          assert @dummy.errors[:avatar_content_type].present?
          expect(@dummy.errors[:avatar_content_type]).to include "is invalid"
        end
      end

      context "with :message option" do
        context "without interpolation" do
          before do
            build_validator content_type: "image/png", message: "should be a PNG image"
            @dummy.stubs(avatar_content_type: "image/jpg")
            @validator.validate(@dummy)
          end

          it "sets a correct error message" do
            expect(@dummy.errors[:avatar_content_type]).to include "should be a PNG image"
          end
        end

        context "with interpolation" do
          before do
            build_validator content_type: "image/png", message: "should have content type %{types}"
            @dummy.stubs(avatar_content_type: "image/jpg")
            @validator.validate(@dummy)
          end

          it "sets a correct error message" do
            expect(@dummy.errors[:avatar_content_type]).to include "should have content type image/png"
          end
        end
      end
    end
  end

  context "blacklist format" do
    context "with an allowed type" do
      context "as a string" do
        before do
          build_validator not: "image/gif"
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end

      context "as an regexp" do
        before do
          build_validator not: /^text\/.*/
          @dummy.stubs(avatar_content_type: "image/jpg")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end

      context "as a list" do
        before do
          build_validator not: ["image/png", "image/jpg", "image/jpeg"]
          @dummy.stubs(avatar_content_type: "image/gif")
          @validator.validate(@dummy)
        end

        it "does not set an error message" do
          assert @dummy.errors[:avatar_content_type].blank?
        end
      end
    end

    context "with a disallowed type" do
      context "as a string" do
        before do
          build_validator not: "image/png"
          @dummy.stubs(avatar_content_type: "image/png")
          @validator.validate(@dummy)
        end

        it "sets a correct default error message" do
          assert @dummy.errors[:avatar_content_type].present?
          expect(@dummy.errors[:avatar_content_type]).to include "is invalid"
        end
      end

      context "as a regexp" do
        before do
          build_validator not: /^text\/.*/
          @dummy.stubs(avatar_content_type: "text/plain")
          @validator.validate(@dummy)
        end

        it "sets a correct default error message" do
          assert @dummy.errors[:avatar_content_type].present?
          expect(@dummy.errors[:avatar_content_type]).to include "is invalid"
        end
      end

      context "with :message option" do
        context "without interpolation" do
          before do
            build_validator not: "image/png", message: "should not be a PNG image"
            @dummy.stubs(avatar_content_type: "image/png")
            @validator.validate(@dummy)
          end

          it "sets a correct error message" do
            expect(@dummy.errors[:avatar_content_type]).to include "should not be a PNG image"
          end
        end

        context "with interpolation" do
          before do
            build_validator not: "image/png", message: "should not have content type %{types}"
            @dummy.stubs(avatar_content_type: "image/png")
            @validator.validate(@dummy)
          end

          it "sets a correct error message" do
            expect(@dummy.errors[:avatar_content_type]).to include "should not have content type image/png"
          end
        end
      end
    end
  end

  context "using the helper" do
    before do
      Dummy.validates_attachment_content_type :avatar, content_type: "image/jpg"
    end

    it "adds the validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_content_type }
    end
  end

  context "given options" do
    it "raises argument error if no required argument was given" do
      assert_raises(ArgumentError) do
        build_validator message: "Some message"
      end
    end

    it "does not raise argument error if :content_type was given" do
      build_validator content_type: "image/jpg"
    end

    it "does not raise argument error if :not was given" do
      build_validator not: "image/jpg"
    end
  end
end
