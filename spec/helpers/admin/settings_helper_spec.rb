# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SettingsHelper do
  describe '#login_activity_title' do
    subject { helper.login_activity_title(activity) }

    let(:activity) { Fabricate.build :login_activity, success: true, user_agent: 'Browser', ip: '10.0.0.0', authentication_method: :password }

    it 'returns a string built from the activity' do
      expect(subject)
        .to eq(<<~STRING.squish)
          Successful sign-in
          with <span class="target">password</span>
          from <span class="target">10.0.0.0</span>
          (<span class="target" title="Browser">Unknown Browser on Unknown Platform</span>)
        STRING
    end
  end
end
