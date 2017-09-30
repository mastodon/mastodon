# frozen_string_literal: true

module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    validates :website, url: true, if: :website?
  end
end
