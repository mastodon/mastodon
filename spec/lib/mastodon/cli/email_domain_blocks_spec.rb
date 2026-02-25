# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/email_domain_blocks'

RSpec.describe Mastodon::CLI::EmailDomainBlocks do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#list' do
    let(:action) { :list }

    context 'with both --only-blocked and --only-with-approval' do
      let(:options) { { only_blocked: true, only_with_approval: true } }

      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'Cannot specify both --only-blocked and --only-with-approval')
      end
    end

    context 'with email domain block records' do
      let!(:parent_block) { Fabricate(:email_domain_block) }
      let!(:child_block) { Fabricate(:email_domain_block, parent: parent_block) }
      let!(:parent_allow_block) { Fabricate(:email_domain_block, allow_with_approval: true) }
      let!(:child_allow_block) { Fabricate(:email_domain_block, parent: parent_allow_block, allow_with_approval: true) }

      it 'lists all the blocks by default' do
        expect { subject }
          .to output_results(
            parent_block.domain,
            child_block.domain,
            parent_allow_block.domain,
            child_allow_block.domain
          )
      end

      context 'with the --only-blocked flag set' do
        let(:options) { { only_blocked: true } }

        it 'lists only blocked domains' do
          expect { subject }
            .to output_results(
              parent_block.domain,
              child_block.domain
            )
            .and not_output_results(
              parent_allow_block.domain,
              child_allow_block.domain
            )
        end
      end

      context 'with the --only-with-approval flag set' do
        let(:options) { { only_with_approval: true } }

        it 'lists only manually approvable domains' do
          expect { subject }
            .to output_results(
              parent_allow_block.domain,
              child_allow_block.domain
            )
            .and not_output_results(
              parent_block.domain,
              child_block.domain
            )
        end
      end
    end
  end

  describe '#add' do
    let(:action) { :add }

    context 'without any options' do
      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'No domain(s) given')
      end
    end

    context 'when blocks exist' do
      let(:options) { {} }
      let(:domain) { 'host.example' }
      let(:arguments) { [domain] }

      before { Fabricate(:email_domain_block, domain: domain) }

      it 'does not add a new block' do
        expect { subject }
          .to output_results('is already blocked')
          .and(not_change(EmailDomainBlock, :count))
      end
    end

    context 'when no blocks exist' do
      let(:domain) { 'host.example' }
      let(:arguments) { [domain] }
      let(:options) { { allow_with_approval: false } }

      it 'adds a new block' do
        expect { subject }
          .to output_results('Added 1')
          .and(change(EmailDomainBlock, :count).by(1))
      end
    end

    context 'with --with-dns-records true' do
      let(:domain) { 'host.example' }
      let(:arguments) { [domain] }
      let(:options) { { allow_with_approval: false, with_dns_records: true } }

      before do
        configure_mx(domain: domain, exchange: 'other.host')
      end

      it 'adds a new block for parent and children' do
        expect { subject }
          .to output_results('Added 2')
          .and(change(EmailDomainBlock, :count).by(2))
      end
    end
  end

  describe '#remove' do
    let(:action) { :remove }

    context 'without any options' do
      it 'warns about usage and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'No domain(s) given')
      end
    end

    context 'when blocks exist' do
      let(:domain) { 'host.example' }
      let(:arguments) { [domain] }

      before { Fabricate(:email_domain_block, domain: domain) }

      it 'removes the block' do
        expect { subject }
          .to output_results('Removed 1')
          .and(change(EmailDomainBlock, :count).by(-1))
      end
    end

    context 'when no blocks exist' do
      let(:domain) { 'host.example' }
      let(:arguments) { [domain] }

      it 'does not remove a block' do
        expect { subject }
          .to output_results('is not yet blocked')
          .and(not_change(EmailDomainBlock, :count))
      end
    end
  end
end
