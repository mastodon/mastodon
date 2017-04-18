# frozen_string_literal: true

require 'rails_helper'

describe LanguageDetector do
  describe 'to_iso_s' do
    it 'detects english language' do
      string = 'Hello and welcome to mastadon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :en
    end

    it 'detects spanish language' do
      string = 'Obtener un Hola y bienvenidos a Mastadon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :es
    end

    it 'defaults to `en` for empty string' do
      string = ''
      result = described_class.new(string).to_iso_s

      expect(result).to eq 'en'
    end
  end
end
