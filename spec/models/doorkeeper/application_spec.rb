# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::Application do
  describe 'Associations' do
    it { is_expected.to have_many(:created_users).class_name('User').inverse_of(:created_by_application).with_foreign_key(:created_by_application_id) }
  end

  describe 'Validations' do
    subject { Fabricate :application }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:uid) }

    it { is_expected.to validate_length_of(:name).is_at_most(described_class::APP_NAME_LIMIT) }
    it { is_expected.to validate_length_of(:redirect_uri).is_at_most(described_class::APP_REDIRECT_URI_LIMIT) }
    it { is_expected.to validate_length_of(:website).is_at_most(described_class::APP_WEBSITE_LIMIT) }
  end

  describe '#redirect_uris' do
    subject { Fabricate.build(:application, redirect_uri:).redirect_uris }

    context 'with single value' do
      let(:redirect_uri) { 'https://test.example/one' }

      it { is_expected.to be_an(Array).and(eq(['https://test.example/one'])) }
    end

    context 'with multiple values' do
      let(:redirect_uri) { "https://test.example/one\nhttps://test.example/two" }

      it { is_expected.to be_an(Array).and(eq(['https://test.example/one', 'https://test.example/two'])) }
    end
  end

  describe '#confirmation_redirect_uri' do
    subject { Fabricate.build(:application, redirect_uri:).confirmation_redirect_uri }

    context 'with single value' do
      let(:redirect_uri) { 'https://test.example/one    ' }

      it { is_expected.to eq('https://test.example/one') }
    end

    context 'with multiple values' do
      let(:redirect_uri) { "https://test.example/one     \nhttps://test.example/two           " }

      it { is_expected.to eq('https://test.example/one') }
    end
  end
end
