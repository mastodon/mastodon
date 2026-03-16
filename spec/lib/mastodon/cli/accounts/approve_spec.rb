# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#approve' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#approve' do
    let(:action) { :approve }
    let(:total_users) { 4 }

    before do
      Form::AdminSettings.new(registrations_mode: 'approved').save
      Fabricate.times(total_users, :user)
    end

    context 'with --all option' do
      let(:options) { { all: true } }

      it 'approves all pending registrations' do
        expect { subject }
          .to output_results('OK')

        expect(User.pluck(:approved).all?(true)).to be(true)
      end
    end

    context 'with --number option' do
      context 'when the number is positive' do
        let(:options) { { number: 2 } }

        it 'approves the earliest n pending registrations but not the remaining ones' do
          expect { subject }
            .to output_results('OK')

          expect(n_earliest_pending_registrations.all?(&:approved?)).to be(true)
          expect(pending_registrations.all?(&:approved?)).to be(false)
        end

        def n_earliest_pending_registrations
          User.order(created_at: :asc).first(options[:number])
        end

        def pending_registrations
          User.order(created_at: :asc).last(total_users - options[:number])
        end
      end

      context 'when the number is negative' do
        let(:options) { { number: -1 } }

        it 'exits with an error message indicating that the number must be positive' do
          expect { subject }
            .to raise_error(Thor::Error, 'Number must be positive')
        end
      end

      context 'when the given number is greater than the number of users' do
        let(:options) { { number: total_users * 2 } }

        it 'approves all users and does not raise any error' do
          expect { subject }
            .to output_results('OK')
          expect(User.pluck(:approved).all?(true)).to be(true)
        end
      end
    end

    context 'with username argument' do
      context 'when the given username is found' do
        let(:user) { User.last }
        let(:arguments) { [user.account.username] }

        it 'approves the specified user successfully' do
          expect { subject }
            .to output_results('OK')

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no such account was found' do
          expect { subject }
            .to raise_error(Thor::Error, 'No such account')
        end
      end
    end
  end
end
