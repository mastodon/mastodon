# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emergency::Trigger do
  describe 'process_event' do
    subject(:process_event) { described_class.process_event(event_name, at_time, counts) }

    let(:rule) { Fabricate('Emergency::Rule') }
    let(:at_time) { Time.now.utc }
    let(:event_name) { 'local:signups' }

    before do
      rule.triggers.create!(event: 'local:signups', threshold: 10, duration_bucket: :hour)
    end

    context 'when called below the threshold' do
      let(:counts) do
        { minute: 9, hour: 9, day: 15 }
      end

      it 'does not trigger the rule' do
        expect { process_event }.to_not change(rule, :triggered_at)
      end
    end

    context 'when called meeting the threshold' do
      let(:counts) do
        { minute: 9, hour: 10, day: 15 }
      end

      it 'triggers the rule' do
        expect { process_event }.to (change { rule.reload.triggered_at }).from(nil).to(at_time.beginning_of_hour)
      end
    end

    context 'when called above the threshold' do
      let(:counts) do
        { minute: 9, hour: 11, day: 15 }
      end

      it 'triggers the rule' do
        expect { process_event }.to (change { rule.reload.triggered_at }).from(nil).to(at_time.beginning_of_hour)
      end
    end

    context 'when called with an unrelated event' do
      let(:event_name) { 'local:posts' }
      let(:counts) do
        { minute: 11, hour: 11, day: 11 }
      end

      it 'does not trigger the rule' do
        expect { process_event }.to_not(change { rule.reload.triggered_at })
      end
    end
  end
end
