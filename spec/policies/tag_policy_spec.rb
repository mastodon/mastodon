# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :show?, :update?, :review? do
    context 'when staff?' do
      it 'permits' do
        expect(subject).to permit(admin, Tag)
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, Tag)
      end
    end
  end
end
