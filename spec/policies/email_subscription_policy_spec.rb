# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailSubscriptionPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :index?, :enable?, :disable?, :purge? do
    context 'when admin' do
      it { is_expected.to permit(admin, EmailSubscription) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, EmailSubscription) }
    end
  end
end
