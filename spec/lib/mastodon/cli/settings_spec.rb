# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/settings'

describe Mastodon::CLI::Settings do
  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe 'subcommand "registrations"' do
    let(:cli) { Mastodon::CLI::Registrations.new }

    before do
      Setting.registrations_mode = nil
    end

    describe '#open' do
      it 'changes "registrations_mode" to "open"' do
        expect { cli.open }.to change(Setting, :registrations_mode).from(nil).to('open')
      end

      it 'displays success message' do
        expect { cli.open }.to output(
          a_string_including('OK')
        ).to_stdout
      end
    end

    describe '#approved' do
      it 'changes "registrations_mode" to "approved"' do
        expect { cli.approved }.to change(Setting, :registrations_mode).from(nil).to('approved')
      end

      it 'displays success message' do
        expect { cli.approved }.to output(
          a_string_including('OK')
        ).to_stdout
      end

      context 'with --require-reason' do
        before do
          cli.options = { require_reason: true }
        end

        it 'changes "registrations_mode" to "approved"' do
          expect { cli.approved }.to change(Setting, :registrations_mode).from(nil).to('approved')
        end

        it 'sets "require_invite_text" to "true"' do
          expect { cli.approved }.to change(Setting, :require_invite_text).from(false).to(true)
        end
      end
    end

    describe '#close' do
      it 'changes "registrations_mode" to "none"' do
        expect { cli.close }.to change(Setting, :registrations_mode).from(nil).to('none')
      end

      it 'displays success message' do
        expect { cli.close }.to output(
          a_string_including('OK')
        ).to_stdout
      end
    end
  end
end
