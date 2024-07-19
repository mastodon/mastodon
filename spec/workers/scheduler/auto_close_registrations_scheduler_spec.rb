# frozen_string_literal: true

require 'rails_helper'

describe Scheduler::AutoCloseRegistrationsScheduler do
  subject { described_class.new }

  describe '#perform' do
    let(:moderator_activity_date) { Time.now.utc }

    before do
      Fabricate(:user, role: UserRole.find_by(name: 'Owner'), current_sign_in_at: 10.years.ago)
      Fabricate(:user, role: UserRole.find_by(name: 'Moderator'), current_sign_in_at: moderator_activity_date)
    end

    context 'when registrations are open' do
      before do
        Setting.registrations_mode = 'open'
      end

      context 'when a moderator has logged in recently' do
        let(:moderator_activity_date) { Time.now.utc }

        it 'does not change registrations mode' do
          expect { subject.perform }.to_not change(Setting, :registrations_mode)
        end
      end

      context 'when a moderator has not recently signed in' do
        let(:moderator_activity_date) { 1.year.ago }

        it 'changes registrations mode from open to approved' do
          expect { subject.perform }.to change(Setting, :registrations_mode).from('open').to('approved')
        end
      end
    end

    context 'when registrations are closed' do
      before do
        Setting.registrations_mode = 'none'
      end

      context 'when a moderator has logged in recently' do
        let(:moderator_activity_date) { Time.now.utc }

        it 'does not change registrations mode' do
          expect { subject.perform }.to_not change(Setting, :registrations_mode)
        end
      end

      context 'when a moderator has not recently signed in' do
        let(:moderator_activity_date) { 1.year.ago }

        it 'does not change registrations mode' do
          expect { subject.perform }.to_not change(Setting, :registrations_mode)
        end
      end
    end
  end
end
