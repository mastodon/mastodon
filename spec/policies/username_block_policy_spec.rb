# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsernameBlockPolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:account) { Fabricate(:account) }

  permissions :index?, :create?, :update?, :destroy? do
    context 'when admin' do
      it { is_expected.to permit(admin, UsernameBlock.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, UsernameBlock.new) }
    end
  end
end
