# frozen_string_literal: true

module Statistic
  extend ActiveSupport::Concern

  class_methods do
    def wrap_counts(*values)
      values.each do |value|
        define_method :"#{value}_count" do
          [attributes["#{value}_count"], 0].max
        end
      end
    end
  end
end
