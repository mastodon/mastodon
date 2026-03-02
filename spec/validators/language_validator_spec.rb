# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LanguageValidator do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      def self.name = 'Record'

      attr_accessor :locale

      validates :locale, language: true
    end
  end

  context 'with a nil value' do
    it { is_expected.to allow_value(nil).for(:locale) }
  end

  context 'with an array of values' do
    it { is_expected.to allow_value(%w(en fr)).for(:locale) }

    it { is_expected.to_not allow_value(%w(en fr missing)).for(:locale).with_message(:invalid) }
  end

  context 'with a locale string' do
    it { is_expected.to allow_value('en').for(:locale) }

    it { is_expected.to_not allow_value('missing').for(:locale).with_message(:invalid) }
  end
end
