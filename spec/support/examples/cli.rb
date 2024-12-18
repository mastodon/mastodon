# frozen_string_literal: true

RSpec.shared_examples 'CLI Command' do
  it 'configures Thor to exit on failure' do
    expect(described_class.exit_on_failure?).to be true
  end

  it 'descends from the CLI base class' do
    expect(described_class.new).to be_a(Mastodon::CLI::Base)
  end
end
