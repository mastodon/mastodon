# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :index? do
    context 'with an admin' do
      it { is_expected.to permit(admin, nil) }
    end

    context 'with a non-admin' do
      it { is_expected.to_not permit(account, nil) }
    end
  end
end
