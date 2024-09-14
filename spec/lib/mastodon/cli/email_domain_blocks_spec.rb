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

    context 'with email domain block records' do
      let!(:parent_block) { Fabricate(:email_domain_block) }
      let!(:child_block) { Fabricate(:email_domain_block, parent: parent_block) }

      it 'lists the blocks' do
        expect { subject }
          .to output_results(
            parent_block.domain,
            child_block.domain
          )
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

      it 'adds a new block' do
        expect { subject }
          .to output_results('Added 1')
          .and(change(EmailDomainBlock, :count).by(1))
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
