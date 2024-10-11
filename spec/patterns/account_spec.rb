# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  describe described_class::MENTION_RE do
    context 'when string matches' do
      subject { described_class.match(string)[1] }

      context 'with username in the middle of a sentence' do
        let(:string) { 'Hello to @alice from me' }

        it { is_expected.to eq('alice') }
      end

      context 'with username in the beginning of status' do
        let(:string) { '@alice Hey how are you?' }

        it { is_expected.to eq('alice') }
      end

      context 'with full username in string' do
        let(:string) { '@alice@example.com' }

        it { is_expected.to eq('alice@example.com') }
      end

      context 'with full username ending in a dot' do
        let(:string) { 'Hello @alice@example.com.' }

        it { is_expected.to eq('alice@example.com') }
      end

      context 'with dot-prepended usernames' do
        let(:string) { '.@alice I want everybody to see this' }

        it { is_expected.to eq('alice') }
      end

      context 'with mixed-case username' do
        let(:string) { 'Hello to @aLice@Example.com from me' }

        it { is_expected.to eq('aLice@Example.com') }
      end

      context 'with username after the letter ß' do
        let(:string) { 'Hello toß @alice from me' }

        it { is_expected.to eq('alice') }
      end
    end

    context 'when string does not match' do
      subject { described_class.match(string) }

      context 'when email is in string' do
        let(:string) { 'Drop me an e-mail at alice@example.com' }

        it { is_expected.to be_nil }
      end

      context 'when URL is in string' do
        let(:string) { 'Check this out https://medium.com/@alice/some-article#.abcdef123' }

        it { is_expected.to be_nil }
      end

      context 'when URL with query string is present' do
        let(:string) { 'https://example.com/?x=@alice' }

        it { is_expected.to be_nil }
      end
    end
  end
end
