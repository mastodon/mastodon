# frozen_string_literal: true

shared_examples 'A CLI Sub-Command' do
  describe 'Subclass of Base' do
    it 'descends from CLI base class' do
      expect(described_class).to be < Mastodon::CLI::Base
    end
  end

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end
end
