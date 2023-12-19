# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/main'

describe Mastodon::CLI::Main do
  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe 'version' do
    it 'returns the Mastodon version' do
      expect { described_class.new.invoke(:version) }.to output(
        a_string_including(Mastodon::Version.to_s)
      ).to_stdout
    end
  end
end
