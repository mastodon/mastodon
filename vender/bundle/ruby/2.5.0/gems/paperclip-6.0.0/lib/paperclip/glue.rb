require 'paperclip/callbacks'
require 'paperclip/validators'
require 'paperclip/schema'

module Paperclip
  module Glue
    def self.included(base)
      base.extend ClassMethods
      base.send :include, Callbacks
      base.send :include, Validators
      base.send :include, Schema if defined? ActiveRecord::Base

      locale_path = Dir.glob(File.dirname(__FILE__) + "/locales/*.{rb,yml}")
      I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
    end
  end
end
