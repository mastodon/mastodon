# frozen_string_literal: true

module Devise
  class IntegrationTest < ActionDispatch::IntegrationTest
    # %w( get post patch put head delete xml_http_request
    #           xhr get_via_redirect post_via_redirect
    #         ).each do |method|
    %w( get post put ).each do |method|
      if Rails.version >= '5.0.0'
        define_method(method) do |url, options={}|
          if options.empty?
            super url
          else
            super url, options
          end
        end
      else
        define_method(method) do |url, options={}|
          if options[:xhr]==true
            xml_http_request  __method__, url, options[:params] || {}, options[:headers]
          else
            super url, options[:params] || {}, options[:headers]
          end
        end
      end
    end
  end

  class ControllerTestCase < ActionController::TestCase
    # %w( get post patch put head delete xml_http_request
    #           xhr get_via_redirect post_via_redirect
    #         ).each do |method|
    %w( get post put ).each do |method|
      if Rails.version >= '5.0.0'
        define_method(method) do |action, options={}|
          if options.empty?
            super action
          else
            super action, options
          end
        end
      else
        define_method(method) do |action, options={}|
          if options[:xhr]==true
            xml_http_request  __method__, action, options[:params] || {}, options[:headers]
          else
            super action, options[:params] || {}, options[:headers]
          end
        end
      end
    end
  end
end
