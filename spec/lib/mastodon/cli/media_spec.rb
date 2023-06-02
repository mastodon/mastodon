# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/media'

describe Mastodon::CLI::Media do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#remove' do
    context 'with --prune-profiles and --remove-headers' do
      let(:options) { { prune_profiles: true, remove_headers: true } }

      it 'warns about usage and exits' do
        expect { cli.invoke(:remove, [], options) }.to output(
          a_string_including('--prune-profiles and --remove-headers should not be specified simultaneously')
        ).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end
