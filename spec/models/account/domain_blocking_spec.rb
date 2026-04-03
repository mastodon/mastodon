# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::DomainBlocking do
  let(:account) { Fabricate(:account) }

  describe 'Associations' do
    subject { Fabricate.build :account }

    it { is_expected.to have_many(:domain_blocks).class_name(AccountDomainBlock).dependent(:destroy) }
  end

  describe '#block_domain!' do
    subject { account.block_domain!(domain) }

    let(:domain) { 'example.com' }

    it 'creates and returns AccountDomainBlock' do
      expect { expect(subject).to be_a(AccountDomainBlock) }
        .to change { account.domain_blocks.count }.by 1
    end

    context 'with an IDNA domain' do
      subject do
        [
          account.block_domain!(idna_domain),
          account.block_domain!(punycode_domain),
        ]
      end

      let(:idna_domain) { '대한민국.한국' }
      let(:punycode_domain) { 'xn--3e0bs9hfvinn1a.xn--3e0b707e' }

      it 'creates single AccountDomainBlock' do
        expect { expect(subject).to all(be_a AccountDomainBlock) }
          .to change { account.domain_blocks.count }.by 1
      end
    end
  end

  describe '#unblock_domain!' do
    subject { account.unblock_domain!(domain) }

    let(:domain) { 'example.com' }

    context 'when blocking the domain' do
      let(:account_domain_block) { Fabricate(:account_domain_block, domain: domain) }

      before { account.domain_blocks << account_domain_block }

      it 'returns destroyed AccountDomainBlock' do
        expect(subject)
          .to be_a(AccountDomainBlock)
          .and be_destroyed
      end
    end

    context 'when unblocking the domain' do
      it { expect(subject).to be_nil }
    end

    context 'with an IDNA domain' do
      subject { account.unblock_domain!(punycode_domain) }

      let(:idna_domain) { '대한민국.한국' }
      let(:punycode_domain) { 'xn--3e0bs9hfvinn1a.xn--3e0b707e' }

      context 'when blocking the domain' do
        let(:account_domain_block) { Fabricate(:account_domain_block, domain: idna_domain) }

        before { account.domain_blocks << account_domain_block }

        it 'returns destroyed AccountDomainBlock' do
          expect(subject)
            .to be_a(AccountDomainBlock)
            .and be_destroyed
        end
      end

      context 'when unblocking idna domain' do
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#domain_blocking?' do
    subject { account.domain_blocking?(domain) }

    let(:domain) { 'example.com' }

    context 'when blocking the domain' do
      let(:account_domain_block) { Fabricate(:account_domain_block, domain: domain) }

      before { account.domain_blocks << account_domain_block }

      it 'returns true' do
        expect { expect(subject).to be(true) }
          .to execute_queries
      end

      context 'when relations are preloaded' do
        before { account.preload_relations!([], [domain]) }

        it 'does not query the database to get the result' do
          expect { expect(subject).to be(true) }
            .to_not execute_queries
        end
      end
    end

    context 'when not blocking the domain' do
      it { is_expected.to be(false) }
    end
  end
end
