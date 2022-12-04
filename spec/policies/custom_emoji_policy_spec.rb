# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe CustomEmojiPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :enable?, :disable? do
    context 'staff' do
      it 'permits' do
        expect(subject).to permit(admin, CustomEmoji)
      end
    end

    context 'not staff' do
      it 'denies' do
        expect(subject).to_not permit(john, CustomEmoji)
      end
    end
  end

  permissions :create?, :update?, :copy?, :destroy? do
    context 'admin' do
      it 'permits' do
        expect(subject).to permit(admin, CustomEmoji)
      end
    end

    context 'not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, CustomEmoji)
      end
    end
  end
end
