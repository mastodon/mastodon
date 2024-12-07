# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfService do
  describe '#scope_for_notification' do
    subject { terms_of_service.scope_for_notification }

    let(:published_at) { Time.now.utc }
    let(:terms_of_service) { Fabricate(:terms_of_service, published_at: published_at) }
    let(:user_before) { Fabricate(:user, created_at: published_at - 2.days) }
    let(:user_before_unconfirmed) { Fabricate(:user, created_at: published_at - 2.days, confirmed_at: nil) }
    let(:user_before_suspended) { Fabricate(:user, created_at: published_at - 2.days) }
    let(:user_after) { Fabricate(:user, created_at: published_at + 1.hour) }

    before do
      user_before_suspended.account.suspend!
      user_before_unconfirmed
      user_before
      user_after
    end

    it 'includes only users created before the terms of service were published' do
      expect(subject.pluck(:id)).to match_array(user_before.id)
    end
  end
end
