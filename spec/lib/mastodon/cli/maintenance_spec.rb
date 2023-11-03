# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

describe Mastodon::CLI::Maintenance do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#fix_duplicates' do
    context 'when the database version is too old' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2000_01_01_000000) # Earlier than minimum
      end

      it 'Exits with error message' do
        expect { cli.invoke :fix_duplicates }.to output(
          a_string_including('is too old')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when the database version is too new and the user does not continue' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2100_01_01_000000) # Later than maximum
        allow(cli.shell).to receive(:yes?).with('Continue anyway? (Yes/No)').and_return(false).once
      end

      it 'Exits with error message' do
        expect { cli.invoke :fix_duplicates }.to output(
          a_string_including('more recent')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when Sidekiq is running' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2022_01_01_000000) # Higher than minimum, lower than maximum
        allow(Sidekiq::ProcessSet).to receive(:new).and_return [:process]
      end

      it 'Exits with error message' do
        expect { cli.invoke :fix_duplicates }.to output(
          a_string_including('Sidekiq is running')
        ).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end
