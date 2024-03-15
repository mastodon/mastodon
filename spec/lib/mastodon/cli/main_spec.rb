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
        before do
          answer_hostname_incorrectly
        end

        it 'exits with mismatch error message' do
          expect { subject }
            .to raise_error(Thor::Error, /Domains do not match/)
        end
      end

      context 'with a correct response to hostname but no to proceed' do
        before do
          answer_hostname_correctly
          decline_proceed
        end

        it 'passes first step but stops before instructions' do
          expect { subject }
            .to output_results('operation WILL NOT')
            .and raise_error(Thor::Error, /Self-destruct will not begin/)
        end
      end

      context 'with a correct response to hostname and yes to proceed' do
        before do
          answer_hostname_correctly
          accept_proceed
        end

        it 'instructs to set the appropriate environment variable' do
          expect { subject }
            .to output_results(
              'operation WILL NOT',
              'the following variable'
            )
        end
      end

      private

      def answer_hostname_incorrectly
        allow(cli.shell)
          .to receive(:ask)
          .with('Type in the domain of the server to confirm:')
          .and_return('wrong.host')
          .once
      end

      def answer_hostname_correctly
        allow(cli.shell)
          .to receive(:ask)
          .with('Type in the domain of the server to confirm:')
          .and_return(Rails.configuration.x.local_domain)
          .once
      end

      def decline_proceed
        allow(cli.shell)
          .to receive(:no?)
          .with('Are you sure you want to proceed?')
          .and_return(true)
          .once
      end

      def accept_proceed
        allow(cli.shell)
          .to receive(:no?)
          .with('Are you sure you want to proceed?')
          .and_return(false)
          .once
      end
    end
  end
end
