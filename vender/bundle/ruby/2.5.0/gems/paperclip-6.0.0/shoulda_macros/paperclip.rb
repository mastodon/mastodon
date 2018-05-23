require 'paperclip/matchers'

module Paperclip
  # =Paperclip Shoulda Macros
  #
  # These macros are intended for use with shoulda, and will be included into
  # your tests automatically. All of the macros use the standard shoulda
  # assumption that the name of the test is based on the name of the model
  # you're testing (that is, UserTest is the test for the User model), and
  # will load that class for testing purposes.
  module Shoulda
    include Matchers
    # This will test whether you have defined your attachment correctly by
    # checking for all the required fields exist after the definition of the
    # attachment.
    def should_have_attached_file name
      klass   = self.name.gsub(/Test$/, '').constantize
      matcher = have_attached_file name
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end

    # Tests for validations on the presence of the attachment.
    def should_validate_attachment_presence name
      klass   = self.name.gsub(/Test$/, '').constantize
      matcher = validate_attachment_presence name
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end

    # Tests that you have content_type validations specified. There are two
    # options, :valid and :invalid. Both accept an array of strings. The
    # strings should be a list of content types which will pass and fail
    # validation, respectively.
    def should_validate_attachment_content_type name, options = {}
      klass   = self.name.gsub(/Test$/, '').constantize
      valid   = [options[:valid]].flatten
      invalid = [options[:invalid]].flatten
      matcher = validate_attachment_content_type(name).allowing(valid).rejecting(invalid)
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end

    # Tests to ensure that you have file size validations turned on. You
    # can pass the same options to this that you can to
    # validate_attachment_file_size - :less_than, :greater_than, and :in.
    # :less_than checks that a file is less than a certain size, :greater_than
    # checks that a file is more than a certain size, and :in takes a Range or
    # Array which specifies the lower and upper limits of the file size.
    def should_validate_attachment_size name, options = {}
      klass   = self.name.gsub(/Test$/, '').constantize
      min     = options[:greater_than] || (options[:in] && options[:in].first) || 0
      max     = options[:less_than]    || (options[:in] && options[:in].last)  || (1.0/0)
      range   = (min..max)
      matcher = validate_attachment_size(name).in(range)
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end

    # Stubs the HTTP PUT for an attachment using S3 storage.
    #
    # @example
    #   stub_paperclip_s3('user', 'avatar', 'png')
    def stub_paperclip_s3(model, attachment, extension)
      definition = model.gsub(" ", "_").classify.constantize.
                         attachment_definitions[attachment.to_sym]

      path = "http://s3.amazonaws.com/:id/#{definition[:path]}"
      path.gsub!(/:([^\/\.]+)/) do |match|
        "([^\/\.]+)"
      end

      begin
        FakeWeb.register_uri(:put, Regexp.new(path), :body => "OK")
      rescue NameError
        raise NameError, "the stub_paperclip_s3 shoulda macro requires the fakeweb gem."
      end
    end

    # Stub S3 and return a file for attachment. Best with Factory Girl.
    # Uses a strict directory convention:
    #
    #     features/support/paperclip
    #
    # This method is used by the Paperclip-provided Cucumber step:
    #
    #     When I attach a "demo_tape" "mp3" file to a "band" on S3
    #
    # @example
    #   Factory.define :band_with_demo_tape, :parent => :band do |band|
    #     band.demo_tape { band.paperclip_fixture("band", "demo_tape", "png") }
    #   end
    def paperclip_fixture(model, attachment, extension)
      stub_paperclip_s3(model, attachment, extension)
      base_path = File.join(File.dirname(__FILE__), "..", "..",
                            "features", "support", "paperclip")
      File.new(File.join(base_path, model, "#{attachment}.#{extension}"))
    end
  end
end

if defined?(ActionDispatch::Integration::Session)
  class ActionDispatch::IntegrationTest::Session  #:nodoc:
    include Paperclip::Shoulda
  end
elsif defined?(ActionController::Integration::Session)
  class ActionController::Integration::Session  #:nodoc:
    include Paperclip::Shoulda
  end
end

if defined?(FactoryGirl::Factory)
  class FactoryGirl::Factory
    include Paperclip::Shoulda  #:nodoc:
  end
else
  class Factory
    include Paperclip::Shoulda  #:nodoc:
  end
end

if defined?(Minitest)
  class Minitest::Unit::TestCase #:nodoc:
    extend Paperclip::Shoulda
  end
elsif defined?(Test)
  class Test::Unit::TestCase #:nodoc:
    extend Paperclip::Shoulda
  end
end
