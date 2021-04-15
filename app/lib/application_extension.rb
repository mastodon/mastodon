# frozen_string_literal: true

module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    validates :name, length: { maximum: 60 }
    validates :website, url: true, length: { maximum: 2_000 }, if: :website?
    validates :redirect_uri, length: { maximum: 2_000 }
  end
end
