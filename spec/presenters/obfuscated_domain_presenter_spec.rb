# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ObfuscatedDomainPresenter do
  describe '#to_s' do
    subject { described_class.new(domain).to_s }

    context 'with a short domain' do
      let(:domain) { 'abc.com' }

      it { is_expected.to eq('ab*.**m') }
    end

    context 'with a long domain' do
      let(:domain) { 'alphabet.soup.is.good.for.breakfast.and.lunch.and.dinner.org' }

      it { is_expected.to eq('alphabet.soup.is.****.***.*********.***.*****.and.dinner.org') }
    end

    context 'with a domain from the federalized multiverse' do
      let(:domain) { 'mastodon.social' }

      it { is_expected.to eq('mast****.***ial') }
    end

    context 'with a series of dots' do
      let(:domain) { '.....' }

      it { is_expected.to eq('.....') }
    end
  end
end
