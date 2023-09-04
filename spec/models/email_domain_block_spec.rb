require 'rails_helper'

RSpec.describe EmailDomainBlock, type: :model do
  describe 'validations' do
    it 'has a valid fabricator' do
      email_domain_block = Fabricate.build(:email_domain_block)
      expect(email_domain_block).to be_valid
    end
  end

  describe 'block?' do
    let(:input) { nil }

    context 'given an e-mail address' do
      let(:input) { "foo@#{domain}" }

      context do
        let(:domain) { 'example.com' }

        it 'returns true if the domain is blocked' do
          Fabricate(:email_domain_block, domain: 'example.com')
          expect(EmailDomainBlock.block?(input)).to be true
        end

        it 'returns false if the domain is not blocked' do
          Fabricate(:email_domain_block, domain: 'other-example.com')
          expect(EmailDomainBlock.block?(input)).to be false
        end
      end

      context do
        let(:domain) { 'mail.example.com' }

        it 'returns true if it is a subdomain of a blocked domain' do
          Fabricate(:email_domain_block, domain: 'example.com')
          expect(described_class.block?(input)).to be true
        end
      end
    end

    context 'given an array of domains' do
      let(:input) { %w(foo.com mail.foo.com) }

      it 'returns true if the domain is blocked' do
        Fabricate(:email_domain_block, domain: 'mail.foo.com')
        expect(EmailDomainBlock.block?(input)).to be true
      end
    end
  end
end
