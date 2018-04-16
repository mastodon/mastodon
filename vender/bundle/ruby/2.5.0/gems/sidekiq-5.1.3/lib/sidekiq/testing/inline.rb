# frozen_string_literal: true
require 'sidekiq/testing'

##
# The Sidekiq inline infrastructure overrides perform_async so that it
# actually calls perform instead. This allows workers to be run inline in a
# testing environment.
#
# This is similar to `Resque.inline = true` functionality.
#
# Example:
#
#   require 'sidekiq/testing/inline'
#
#   $external_variable = 0
#
#   class ExternalWorker
#     include Sidekiq::Worker
#
#     def perform
#       $external_variable = 1
#     end
#   end
#
#   assert_equal 0, $external_variable
#   ExternalWorker.perform_async
#   assert_equal 1, $external_variable
#
Sidekiq::Testing.inline!
