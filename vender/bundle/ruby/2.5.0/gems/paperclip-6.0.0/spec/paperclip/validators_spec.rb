require 'spec_helper'

describe Paperclip::Validators do
  context "using the helper" do
    before do
      rebuild_class
      Dummy.validates_attachment :avatar, presence: true, content_type: { content_type: "image/jpeg" }, size: { in: 0..10240 }
    end

    it "adds the attachment_presence validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_presence }
    end

    it "adds the attachment_content_type validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_content_type }
    end

    it "adds the attachment_size validator to the class" do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_size }
    end

    it 'prevents you from attaching a file that violates that validation' do
      Dummy.class_eval{ validate(:name) { raise "DO NOT RUN THIS" } }
      dummy = Dummy.new(avatar: File.new(fixture_file("12k.png")))
      expect(dummy.errors.keys).to match_array [:avatar_content_type, :avatar, :avatar_file_size]
      assert_raises(RuntimeError){ dummy.valid? }
    end
  end

  context 'using the helper with array of validations' do
    before do
      rebuild_class
      Dummy.validates_attachment :avatar, file_type_ignorance: true, file_name: [
          { matches: /\A.*\.jpe?g\z/i, message: :invalid_extension },
          { matches: /\A.{,8}\..+\z/i, message: [:too_long, count: 8] },
      ]
    end

    it 'adds the attachment_file_name validator to the class' do
      assert Dummy.validators_on(:avatar).any?{ |validator| validator.kind == :attachment_file_name }
    end

    it 'adds the attachment_file_name validator with two validations' do
      assert_equal 2, Dummy.validators_on(:avatar).select{ |validator| validator.kind == :attachment_file_name }.size
    end

    it 'prevents you from attaching a file that violates all of these validations' do
      Dummy.class_eval{ validate(:name) { raise 'DO NOT RUN THIS' } }
      dummy = Dummy.new(avatar: File.new(fixture_file('spaced file.png')))
      expect(dummy.errors.keys).to match_array [:avatar, :avatar_file_name]
      assert_raises(RuntimeError){ dummy.valid? }
    end

    it 'prevents you from attaching a file that violates only first of these validations' do
      Dummy.class_eval{ validate(:name) { raise 'DO NOT RUN THIS' } }
      dummy = Dummy.new(avatar: File.new(fixture_file('5k.png')))
      expect(dummy.errors.keys).to match_array [:avatar, :avatar_file_name]
      assert_raises(RuntimeError){ dummy.valid? }
    end

    it 'prevents you from attaching a file that violates only second of these validations' do
      Dummy.class_eval{ validate(:name) { raise 'DO NOT RUN THIS' } }
      dummy = Dummy.new(avatar: File.new(fixture_file('spaced file.jpg')))
      expect(dummy.errors.keys).to match_array [:avatar, :avatar_file_name]
      assert_raises(RuntimeError){ dummy.valid? }
    end

    it 'allows you to attach a file that does not violate these validations' do
      dummy = Dummy.new(avatar: File.new(fixture_file('rotated.jpg')))
      expect(dummy.errors.full_messages).to be_empty
      assert dummy.valid?
    end
  end

  context "using the helper with a conditional" do
    before do
      rebuild_class
      Dummy.validates_attachment :avatar, presence: true,
        content_type: { content_type: "image/jpeg" },
        size: { in: 0..10240 },
        if: :title_present?
    end

    it "validates the attachment if title is present" do
      Dummy.class_eval do
        def title_present?
          true
        end
      end
      dummy = Dummy.new(avatar: File.new(fixture_file("12k.png")))
      expect(dummy.errors.keys).to match_array [:avatar_content_type, :avatar, :avatar_file_size]
    end

    it "does not validate attachment if title is not present" do
      Dummy.class_eval do
        def title_present?
          false
        end
      end
      dummy = Dummy.new(avatar: File.new(fixture_file("12k.png")))
      assert_equal [], dummy.errors.keys
    end
  end

  context 'with no other validations on the Dummy#avatar attachment' do
    before do
      reset_class("Dummy")
      Dummy.has_attached_file :avatar
      Paperclip.reset_duplicate_clash_check!
    end

    it 'raises an error when no content_type validation exists' do
      assert_raises(Paperclip::Errors::MissingRequiredValidatorError) do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end

    it 'does not raise an error when a content_type validation exists' do
      Dummy.validates_attachment :avatar, content_type: { content_type: "image/jpeg" }

      assert_nothing_raised do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end

    it 'does not raise an error when a content_type validation exists using validates_with' do
      Dummy.validates_with Paperclip::Validators::AttachmentContentTypeValidator, attributes: :attachment, content_type: 'images/jpeg'

      assert_nothing_raised do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end

    it 'does not raise an error when an inherited validator is used' do
      class MyValidator < Paperclip::Validators::AttachmentContentTypeValidator
        def initialize(options)
          options[:content_type] = "images/jpeg" unless options.has_key?(:content_type)
          super
        end
      end
      Dummy.validates_with MyValidator, attributes: :attachment

      assert_nothing_raised do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end

    it 'does not raise an error when a file_name validation exists' do
      Dummy.validates_attachment :avatar, file_name: { matches: /png$/ }

      assert_nothing_raised do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end

    it 'does not raise an error when a the validation has been explicitly rejected' do
      Dummy.validates_attachment :avatar, file_type_ignorance: true

      assert_nothing_raised do
        Dummy.new(avatar: File.new(fixture_file("12k.png")))
      end
    end
  end
end
