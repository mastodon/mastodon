require 'spec_helper'

describe Paperclip::HasAttachedFile do
  context '#define_on' do
    it 'defines a setter on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar=')
    end

    it 'defines a getter on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar')
    end

    it 'defines a query on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar?')
    end

    it 'defines a method on the class to get all of its attachments' do
      assert_adding_attachment('avatar').defines_class_method('attachment_definitions')
    end

    it 'flushes errors as part of validations' do
      assert_adding_attachment('avatar').defines_validation
    end

    it 'registers the attachment with Paperclip::AttachmentRegistry' do
      assert_adding_attachment('avatar').registers_attachment
    end

    it 'defines an after_save callback' do
      assert_adding_attachment('avatar').defines_callback('after_save')
    end

    it 'defines a before_destroy callback' do
      assert_adding_attachment('avatar').defines_callback('before_destroy')
    end

    it 'defines an after_commit callback' do
      assert_adding_attachment('avatar').defines_callback('after_commit')
    end

    context 'when the class does not allow after_commit callbacks' do
      it 'defines an after_destroy callback' do
        assert_adding_attachment(
          'avatar',
          unstub_methods: [:after_commit]
        ).defines_callback('after_destroy')
      end
    end

    it 'defines the Paperclip-specific callbacks' do
      assert_adding_attachment('avatar').defines_callback('define_paperclip_callbacks')
    end

    it 'does not define a media_type check if told not to' do
      assert_adding_attachment('avatar').does_not_set_up_media_type_check_validation
    end

    it 'does define a media_type check if told to' do
      assert_adding_attachment('avatar').sets_up_media_type_check_validation
    end
  end

  private

  def assert_adding_attachment(attachment_name, options={})
    AttachmentAdder.new(attachment_name, options)
  end

  class AttachmentAdder
    include Mocha::API
    include RSpec::Matchers

    def initialize(attachment_name, options = {})
      @attachment_name = attachment_name
      @stubbed_class = stub_class
      if options.present?
        options[:unstub_methods].each do |method|
          @stubbed_class.unstub(method)
        end
      end
    end

    def defines_method(method_name)
      a_class = @stubbed_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      expect(a_class).to have_received(:define_method).with(method_name)
    end

    def defines_class_method(method_name)
      a_class = @stubbed_class
      a_class.class.stubs(:define_method)

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      expect(a_class).to have_received(:extend).with(Paperclip::HasAttachedFile::ClassMethods)
    end

    def defines_validation
      a_class = @stubbed_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      expect(a_class).to have_received(:validates_each).with(@attachment_name)
    end

    def registers_attachment
      a_class = @stubbed_class
      Paperclip::AttachmentRegistry.stubs(:register)

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {size: 1})

      expect(Paperclip::AttachmentRegistry).to have_received(:register).with(a_class, @attachment_name, {size: 1})
    end

    def defines_callback(callback_name)
      a_class = @stubbed_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      expect(a_class).to have_received(callback_name.to_sym)
    end

    def does_not_set_up_media_type_check_validation
      a_class = stub_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, { validate_media_type: false })

      expect(a_class).to have_received(:validates_media_type_spoof_detection).never
    end

    def sets_up_media_type_check_validation
      a_class = stub_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, { validate_media_type: true })

      expect(a_class).to have_received(:validates_media_type_spoof_detection)
    end

    private

    def stub_class
      stub('class',
           validates_each: nil,
           define_method: nil,
           after_save: nil,
           before_destroy: nil,
           after_commit: nil,
           after_destroy: nil,
           define_paperclip_callbacks: nil,
           extend: nil,
           name: 'Billy',
           validates_media_type_spoof_detection: nil
          )
    end
  end
end
