# frozen_string_literal: true

module ApplicationExtension
  extend ActiveSupport::Concern

  included do
    validates :website, url: true, unless: 'website.blank?'
  end
end
