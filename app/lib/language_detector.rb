# frozen_string_literal: true

class LanguageDetector
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def to_iso_s
    WhatLanguage.new(:all).language_iso(text) || 'en'
  end
end
