# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/settings'

RSpec.describe Mastodon::CLI::Settings do
  it_behaves_like 'CLI Command'

  describe 'subcommand "registrations"' do
    subject { cli.invoke(action, arguments, options) }

    let(:cli) { Mastodon::CLI::Registrations.new }
    let(:arguments) { [] }
    let(:options) { {} }

    before do
      Setting.registrations_mode = nil
    end

    describe '#open' do
      let(:action) { :open }

      it 'changes "registrations_mode" to "open" and displays success' do
        expect { subject }
          .to change(Setting, :registrations_mode).from(nil).to('open')
          .and output_results('OK')
      end
    end

    describe '#approved' do
      let(:action) { :approved }

      it 'changes "registrations_mode" to "approved" and displays success' do
        expect { subject }
          .to change(Setting, :registrations_mode).from(nil).to('approved')
          .and output_results('OK')
      end

      context 'with --require-reason' do
        let(:options) { { require_reason: true } }

        it 'changes registrations_mode and require_invite_text' do
          expect { subject }
            .to output_results('OK')
            .and change(Setting, :registrations_mode).from(nil).to('approved')
            .and change(Setting, :require_invite_text).from(false).to(true)
        end
      end
    end

    describe '#close' do
      let(:action) { :close }

      it 'changes "registrations_mode" to "none" and displays success' do
        expect { subject }
          .to change(Setting, :registrations_mode).from(nil).to('none')
          .and output_results('OK')
      end
    end
  end
end
