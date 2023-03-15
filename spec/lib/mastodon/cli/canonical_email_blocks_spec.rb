# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/canonical_email_blocks'

describe Mastodon::CLI::CanonicalEmailBlocks do
  let(:cli) { described_class.new }

  it_behaves_like 'A CLI Sub-Command'

  describe '#find' do
    let(:arguments) { ['user@example.com'] }

    context 'when a block is present' do
      before { Fabricate(:canonical_email_block, email: 'user@example.com') }

      it 'announces the presence of the block' do
        expect { cli.invoke(:find, arguments) }.to output(
          a_string_including('user@example.com is blocked')
        ).to_stdout
      end
    end

    context 'when a block is not present' do
      it 'announces the absence of the block' do
        expect { cli.invoke(:find, arguments) }.to output(
          a_string_including('user@example.com is not blocked')
        ).to_stdout
      end
    end
  end

  describe '#remove' do
    let(:arguments) { ['user@example.com'] }

    context 'when a block is present' do
      before { Fabricate(:canonical_email_block, email: 'user@example.com') }

      it 'removes the block' do
        expect { cli.invoke(:remove, arguments) }.to output(
          a_string_including('Unblocked user@example.com')
        ).to_stdout

        expect(CanonicalEmailBlock.matching_email('user@example.com')).to be_empty
      end
    end

    context 'when a block is not present' do
      it 'announces the absence of the block' do
        expect { cli.invoke(:remove, arguments) }.to output(
          a_string_including('user@example.com is not blocked')
        ).to_stdout
      end
    end
  end
end
