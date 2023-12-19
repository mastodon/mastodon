# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/migration_warning'

describe Mastodon::MigrationWarning do
  describe 'migration_duration_warning' do
    before do
      allow(migration).to receive(:valid_environment?).and_return(true)
      allow(migration).to receive(:sleep).with(1)
    end

    let(:migration) { Class.new(ActiveRecord::Migration[6.1]).extend(described_class) }

    context 'with the default message' do
      it 'warns about long migrations' do
        expectation = expect { migration.migration_duration_warning }

        expectation.to output(/interrupt this migration/).to_stdout
        expectation.to output(/Continuing in 5/).to_stdout
      end
    end

    context 'with an additional message' do
      it 'warns about long migrations' do
        expectation = expect { migration.migration_duration_warning('Get ready for it') }

        expectation.to output(/interrupt this migration/).to_stdout
        expectation.to output(/Get ready for it/).to_stdout
        expectation.to output(/Continuing in 5/).to_stdout
      end
    end
  end
end
