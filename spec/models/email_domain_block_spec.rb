# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailDomainBlock do
  describe 'block?' do
    subject { described_class.block?(input) }

    let(:input) { nil }

    context 'when given an e-mail address' do
      let(:input) { "foo@#{domain}" }

      context 'with a top level domain' do
        let(:domain) { 'example.com' }

        it 'returns true if the domain is blocked' do
          Fabricate(:email_domain_block, domain: 'example.com')
          expect(subject).to be true
        end

        it 'returns false if the domain is not blocked' do
          Fabricate(:email_domain_block, domain: 'other-example.com')
          expect(subject).to be false
        end
      end

      context 'with a subdomain' do
        let(:domain) { 'mail.example.com' }

        it 'returns true if it is a subdomain of a blocked domain' do
          Fabricate(:email_domain_block, domain: 'example.com')
          expect(subject).to be true
        end
      end
    end

    context 'when given an array of domains' do
      let(:input) { %w(foo.com mail.foo.com) }

      it 'returns true if the domain is blocked' do
        Fabricate(:email_domain_block, domain: 'mail.foo.com')
        expect(subject).to be true
      end
    end

    context 'when given nil' do
      it { is_expected.to be false }
    end

    context 'when given empty string' do
      let(:input) { '' }

      it { is_expected.to be true }
    end
  end

  describe '.requires_approval?' do
    subject { described_class.requires_approval?(input) }

    let(:input) { nil }

    context 'with a matching block requiring approval' do
      before { Fabricate :email_domain_block, domain: input, allow_with_approval: true }

      let(:input) { 'host.example' }

      it { is_expected.to be true }
    end

    context 'with a matching block not requiring approval' do
      before { Fabricate :email_domain_block, domain: input, allow_with_approval: false }

      let(:input) { 'host.example' }

      it { is_expected.to be false }
    end
  end
end
