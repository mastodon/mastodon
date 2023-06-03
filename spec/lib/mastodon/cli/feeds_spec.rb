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

  describe '#clear' do
    before do
      allow(redis).to receive(:del).with(redis.keys('feed:*'))
    end

    it 'clears the redis `feed:*` namespace' do
      expect { cli.invoke(:clear) }.to output(
        a_string_including('OK')
      ).to_stdout
    end
  end
end
