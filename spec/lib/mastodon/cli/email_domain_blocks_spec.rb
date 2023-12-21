# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/email_domain_blocks'

describe Mastodon::CLI::EmailDomainBlocks do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI Command'

  describe '#list' do
    context 'with email domain block records' do
      let!(:parent_block) { Fabricate(:email_domain_block) }
      let!(:child_block) { Fabricate(:email_domain_block, parent: parent_block) }
      let(:options) { {} }

      it 'lists the blocks' do
        expect { cli.invoke(:list, [], options) }.to output(
          a_string_including(parent_block.domain)
          .and(a_string_including(child_block.domain))
        ).to_stdout
      end
    end
  end

  describe '#add' do
    context 'without any options' do
      let(:options) { {} }

      it 'warns about usage and exits' do
        expect { cli.invoke(:add, [], options) }.to output(
          a_string_including('No domain(s) given')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when blocks exist' do
      let(:options) { {} }
      let(:domain) { 'host.example' }

      before { Fabricate(:email_domain_block, domain: domain) }

      it 'does not add a new block' do
        expect { cli.invoke(:add, [domain], options) }.to output(
          a_string_including('is already blocked')
        ).to_stdout
          .and(not_change(EmailDomainBlock, :count))
      end
    end

    context 'when no blocks exist' do
      let(:options) { {} }
      let(:domain) { 'host.example' }

      it 'adds a new block' do
        expect { cli.invoke(:add, [domain], options) }.to output(
          a_string_including('Added 1')
        ).to_stdout
          .and(change(EmailDomainBlock, :count).by(1))
      end
    end
  end

  describe '#remove' do
    context 'without any options' do
      let(:options) { {} }

      it 'warns about usage and exits' do
        expect { cli.invoke(:remove, [], options) }.to output(
          a_string_including('No domain(s) given')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when blocks exist' do
      let(:options) { {} }
      let(:domain) { 'host.example' }

      before { Fabricate(:email_domain_block, domain: domain) }

      it 'removes the block' do
        expect { cli.invoke(:remove, [domain], options) }.to output(
          a_string_including('Removed 1')
        ).to_stdout
          .and(change(EmailDomainBlock, :count).by(-1))
      end
    end

    context 'when no blocks exist' do
      let(:options) { {} }
      let(:domain) { 'host.example' }

      it 'does not remove a block' do
        expect { cli.invoke(:remove, [domain], options) }.to output(
          a_string_including('is not yet blocked')
        ).to_stdout
          .and(not_change(EmailDomainBlock, :count))
      end
    end
  end
end
