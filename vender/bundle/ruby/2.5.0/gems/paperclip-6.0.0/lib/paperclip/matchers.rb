require 'paperclip/matchers/have_attached_file_matcher'
require 'paperclip/matchers/validate_attachment_presence_matcher'
require 'paperclip/matchers/validate_attachment_content_type_matcher'
require 'paperclip/matchers/validate_attachment_size_matcher'

module Paperclip
  module Shoulda
    # Provides RSpec-compatible & Test::Unit-compatible matchers for testing Paperclip attachments.
    #
    # *RSpec*
    #
    # In spec_helper.rb, you'll need to require the matchers:
    #
    #   require "paperclip/matchers"
    #
    # And _include_ the module:
    #
    #   RSpec.configure do |config|
    #     config.include Paperclip::Shoulda::Matchers
    #   end
    #
    # Example:
    #   describe User do
    #     it { should have_attached_file(:avatar) }
    #     it { should validate_attachment_presence(:avatar) }
    #     it { should validate_attachment_content_type(:avatar).
    #                   allowing('image/png', 'image/gif').
    #                   rejecting('text/plain', 'text/xml') }
    #     it { should validate_attachment_size(:avatar).
    #                   less_than(2.megabytes) }
    #   end
    #
    #
    # *TestUnit*
    #
    # In test_helper.rb, you'll need to require the matchers as well:
    #
    #   require "paperclip/matchers"
    #
    # And _extend_ the module:
    #
    #   class ActiveSupport::TestCase
    #     extend Paperclip::Shoulda::Matchers
    #
    #     #...other initializers...#
    #   end
    #
    # Example:
    #   require 'test_helper'
    #
    #   class UserTest < ActiveSupport::TestCase
    #     should have_attached_file(:avatar)
    #     should validate_attachment_presence(:avatar)
    #     should validate_attachment_content_type(:avatar).
    #                  allowing('image/png', 'image/gif').
    #                  rejecting('text/plain', 'text/xml')
    #     should validate_attachment_size(:avatar).
    #                  less_than(2.megabytes)
    #   end
    #
    module Matchers
    end
  end
end
