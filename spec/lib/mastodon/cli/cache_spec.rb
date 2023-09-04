# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/cache'

describe Mastodon::CLI::Cache do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#clear' do
    before { allow(Rails.cache).to receive(:clear) }

    it 'clears the Rails cache' do
      expect { cli.invoke(:clear) }.to output(
        a_string_including('OK')
      ).to_stdout
      expect(Rails.cache).to have_received(:clear)
    end
  end

  describe '#recount' do
    context 'with the `accounts` argument' do
      let(:arguments) { ['accounts'] }
      let(:account_stat) { Fabricate(:account_stat) }

      before do
        account_stat.update(statuses_count: 123)
      end

      it 're-calculates account records in the cache' do
        expect { cli.invoke(:recount, arguments) }.to output(
          a_string_including('OK')
        ).to_stdout

        expect(account_stat.reload.statuses_count).to be_zero
      end
    end

    context 'with the `statuses` argument' do
      let(:arguments) { ['statuses'] }
      let(:status_stat) { Fabricate(:status_stat) }

      before do
        status_stat.update(replies_count: 123)
      end

      it 're-calculates account records in the cache' do
        expect { cli.invoke(:recount, arguments) }.to output(
          a_string_including('OK')
        ).to_stdout

        expect(status_stat.reload.replies_count).to be_zero
      end
    end

    context 'with an unknown type' do
      let(:arguments) { ['other-type'] }

      it 'Exits with an error message' do
        expect { cli.invoke(:recount, arguments) }.to output(
          a_string_including('Unknown')
        ).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end
