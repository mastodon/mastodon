# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :update?, :show?, :destroy? do
    context 'when admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Settings)
      end
    end

    context 'with !admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Settings)
      end
    end
  end
end
