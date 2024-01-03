# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/main'

describe Mastodon::CLI::Main do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#version' do
    let(:action) { :version }

    it 'returns the Mastodon version' do
      expect { subject }
        .to output_results(Mastodon::Version.to_s)
    end
  end

  describe '#self_destruct' do
    let(:action) { :self_destruct }

    context 'with self destruct mode enabled' do
      before do
        allow(SelfDestructHelper).to receive(:self_destruct?).and_return(true)
      end

      context 'with pending accounts' do
        before { Fabricate(:account) }

        it 'reports about pending accounts' do
          expect { subject }
            .to output_results(
              'already enabled',
              'still pending deletion'
            )
            .and raise_error(SystemExit)
        end
      end

      context 'with sidekiq notices being processed' do
        before do
          Account.delete_all
          stats_double = instance_double(Sidekiq::Stats, enqueued: 5)
          allow(Sidekiq::Stats).to receive(:new).and_return(stats_double)
        end

        it 'reports about notices' do
          expect { subject }
            .to output_results(
              'already enabled',
              'notices are still being'
            )
            .and raise_error(SystemExit)
        end
      end

      context 'with sidekiq failed deliveries' do
        before do
          Account.delete_all
          stats_double = instance_double(Sidekiq::Stats, enqueued: 0, retry_size: 10)
          allow(Sidekiq::Stats).to receive(:new).and_return(stats_double)
        end

        it 'reports about notices' do
          expect { subject }
            .to output_results(
              'already enabled',
              'some have failed and are scheduled'
            )
            .and raise_error(SystemExit)
        end
      end

      context 'with self descruct mode ready' do
        before do
          Account.delete_all
          stats_double = instance_double(Sidekiq::Stats, enqueued: 0, retry_size: 0)
          allow(Sidekiq::Stats).to receive(:new).and_return(stats_double)
        end

        it 'reports about notices' do
          expect { subject }
            .to output_results(
              'already enabled',
              'can safely delete all data'
            )
            .and raise_error(SystemExit)
        end
      end
    end

    context 'with self destruct mode disabled' do
      before do
        allow(SelfDestructHelper).to receive(:self_destruct?).and_return(false)
      end

      context 'with an incorrect response to hostname' do
        let(:prompt_double) { instance_double(TTY::Prompt, ask: 'wrong') }

        before do
          allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
        end

        it 'reports failed answer' do
          expect { subject }
            .to raise_error(SystemExit)
        end
      end

      context 'with a correct response to hostname' do
        # TODO: Update after tty-prompt replace with Thor methods
        let(:prompt_double) { instance_double(TTY::Prompt, ask: Rails.configuration.x.local_domain, warn: nil, no?: false, ok: nil) }

        before do
          allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
        end

        it 'instructs to set the appropriate environment variable' do
          expect { subject }
            .to_not raise_error
          # TODO: Update after tty-prompt replace with Thor methods
          expect(prompt_double).to have_received(:ok).with(/add the following variable/)
        end
      end
    end
  end
end
