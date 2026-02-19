# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/canonical_email_blocks'

RSpec.describe Mastodon::CLI::CanonicalEmailBlocks do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#find' do
    let(:action) { :find }
    let(:arguments) { ['user@example.com'] }

    context 'when a block is present' do
      before { Fabricate(:canonical_email_block, email: 'user@example.com') }

      it 'announces the presence of the block' do
        expect { subject }
          .to output_results('user@example.com is blocked')
      end
    end

    context 'when a block is not present' do
      it 'announces the absence of the block' do
        expect { subject }
          .to output_results('user@example.com is not blocked')
      end
    end
  end

  describe '#remove' do
    let(:action) { :remove }
    let(:arguments) { ['user@example.com'] }

    context 'when a block is present' do
      before { Fabricate(:canonical_email_block, email: 'user@example.com') }

      it 'removes the block' do
        expect { subject }
          .to output_results('Unblocked user@example.com')

        expect(CanonicalEmailBlock.matching_email('user@example.com')).to be_empty
      end
    end

    context 'when a block is not present' do
      it 'announces the absence of the block' do
        expect { subject }
          .to output_results('user@example.com is not blocked')
      end
    end
  end
end
