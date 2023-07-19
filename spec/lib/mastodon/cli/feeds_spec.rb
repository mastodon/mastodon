# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/feeds'

describe Mastodon::CLI::Feeds do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#build' do
    before { Fabricate(:account) }

    context 'with --all option' do
      let(:options) { { all: true } }

      it 'regenerates feeds for all accounts' do
        expect { cli.invoke(:build, [], options) }.to output(
          a_string_including('Regenerated feeds')
        ).to_stdout
      end
    end

    context 'with a username' do
      before { Fabricate(:account, username: 'alice') }

      let(:arguments) { ['alice'] }

      it 'regenerates feeds for the account' do
        expect { cli.invoke(:build, arguments) }.to output(
          a_string_including('OK')
        ).to_stdout
      end
    end

    context 'with invalid username' do
      let(:arguments) { ['invalid-username'] }

      it 'displays an error and exits' do
        expect { cli.invoke(:build, arguments) }.to output(
          a_string_including('No such account')
        ).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#clear' do
    before do
      allow(redis).to receive(:del).with(key_namespace)
    end

    it 'clears the redis `feed:*` namespace' do
      expect { cli.invoke(:clear) }.to output(
        a_string_including('OK')
      ).to_stdout

      expect(redis).to have_received(:del).with(key_namespace).once
    end

    def key_namespace
      redis.keys('feed:*')
    end
  end
end
