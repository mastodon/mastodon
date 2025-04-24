# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Fasp::ProviderPolicy, type: :policy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:user) { Fabricate(:account) }

  shared_examples 'admin only' do |target|
    let(:provider) { target.is_a?(Symbol) ? Fabricate(target) : target }

    context 'with an admin' do
      it 'permits' do
        expect(subject).to permit(admin, provider)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(subject).to_not permit(user, provider)
      end
    end
  end

  permissions :index?, :create? do
    it_behaves_like 'admin only', Fasp::Provider
  end

  permissions :show?, :create?, :update?, :destroy? do
    it_behaves_like 'admin only', :fasp_provider
  end
end
