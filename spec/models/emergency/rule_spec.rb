# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emergency::Rule do
  describe '#active?' do
    context 'when the rule is not active' do
      let(:rule) { Fabricate(:'Emergency::Rule') }

      it 'returns false' do
        expect(rule.active?).to be false
      end
    end

    context 'when the rule is active' do
      let(:rule) { Fabricate(:'Emergency::Rule') }

      before do
        rule.trigger!(1.hour.ago)
      end

      it 'returns true' do
        expect(rule.active?).to be true
      end
    end
  end

  describe '#deactivate!' do
    let(:rule) { Fabricate(:'Emergency::Rule', name: 'active') }

    before do
      rule.trigger!(1.hour.ago)
    end

    it 'nullifies triggered_at' do
      expect { rule.deactivate! }.to change(rule, :triggered_at).to(nil)
    end
  end

  describe '#trigger!' do
    context 'when the rule is inactive' do
      subject(:trigger!) { rule.trigger!(Time.now.utc.beginning_of_day) }

      let(:rule) { Fabricate(:'Emergency::Rule', duration: duration) }

      context 'when the rule has a set duration' do
        let(:duration) { 60 }

        it 'sets triggered_at' do
          expect { trigger! }.to change(rule, :triggered_at).from(nil)
        end
      end

      context 'when the rule has no set duration' do
        let(:duration) { nil }

        it 'sets triggered_at' do
          expect { trigger! }.to change(rule, :triggered_at).from(nil)
        end
      end
    end

    context 'when the rule is already active' do
      subject(:trigger!) { rule.trigger!(Time.now.utc.beginning_of_day) }

      let(:rule) { Fabricate(:'Emergency::Rule', duration: duration) }

      before do
        rule.trigger!(1.day.ago)
      end

      context 'when the rule has a set duration' do
        let(:duration) { 60 }

        it 'does not change triggered_at' do
          expect { trigger! }.to_not change(rule, :triggered_at)
        end
      end

      context 'when the rule has no set duration' do
        let(:duration) { nil }

        it 'does not change triggered_at' do
          expect { trigger! }.to_not change(rule, :triggered_at)
        end
      end
    end
  end
end
