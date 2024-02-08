# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/feeds'

describe Mastodon::CLI::Feeds do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#build' do
    let(:action) { :build }

    before { Fabricate(:account) }

    context 'with --all option' do
      let(:options) { { all: true } }

      it 'regenerates feeds for all accounts' do
        expect { subject }
          .to output_results('Regenerated feeds')
      end
    end

    context 'with a username' do
      before { Fabricate(:account, username: 'alice') }

      let(:arguments) { ['alice'] }

      it 'regenerates feeds for the account' do
        expect { subject }
          .to output_results('OK')
      end
    end

    context 'with invalid username' do
      let(:arguments) { ['invalid-username'] }

      it 'displays an error and exits' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end
  end

  describe '#clear' do
    let(:action) { :clear }

    before do
      allow(redis).to receive(:del).with(key_namespace)
    end

    it 'clears the redis `feed:*` namespace' do
      expect { subject }
        .to output_results('OK')

      expect(redis).to have_received(:del).with(key_namespace).once
    end

    def key_namespace
      redis.keys('feed:*')
    end
  end
end
