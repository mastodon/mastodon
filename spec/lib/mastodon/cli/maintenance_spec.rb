# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

describe Mastodon::CLI::Maintenance do
  it_behaves_like 'A CLI Sub-Command'

  describe 'fix_duplicates' do
    before do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).with('Continue anyway? (Yes/No)').and_return true
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).with('Continue? (Yes/No)').and_return true
    end

    it 'fixes db dupes and rebuilds indexes' do
      expect { described_class.new.invoke(:fix_duplicates) }.to output(
        a_string_including('Finished!')
      ).to_stdout
    end
  end
end
