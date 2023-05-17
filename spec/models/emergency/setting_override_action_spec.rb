# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Emergency::SettingOverrideAction do
  describe 'overridden_setting' do
    let(:rule) { Fabricate('Emergency::Rule') }
    let(:account) { Fabricate(:user).account }
    let(:new_users_only) { false }

    before do
      rule.setting_override_actions.create!(setting: 'registrations_mode', value: 'none')
    end

    context 'when no rule is enabled' do
      it 'returns nil' do
        expect(described_class.overridden_setting(:registrations_mode)).to be_nil
      end
    end

    context 'when triggering a rule' do
      it 'correctly invalidates cache and closes registrations' do
        expect { rule.trigger!(Time.now.utc) }.to change { described_class.overridden_setting('registrations_mode') }.from(nil).to('none')
      end
    end

    context 'when deactivating a rule' do
      before do
        rule.trigger!(Time.now.utc)
      end

      it 'correctly invalidates cache and opens registrations' do
        expect { rule.deactivate! }.to change { described_class.overridden_setting('registrations_mode') }.from('none').to(nil)
      end
    end
  end
end
