# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Devise
  class TimeInflector
    include ActionView::Helpers::DateHelper

    class << self
      attr_reader :instance
      delegate :time_ago_in_words, to: :instance
    end

    @instance = new
  end
end
