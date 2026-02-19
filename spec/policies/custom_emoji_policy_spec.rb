# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomEmojiPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :enable?, :disable? do
    context 'when staff' do
      it 'permits' do
        expect(subject).to permit(admin, CustomEmoji)
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john, CustomEmoji)
      end
    end
  end

  permissions :create?, :update?, :copy?, :destroy? do
    context 'when admin' do
      it 'permits' do
        expect(subject).to permit(admin, CustomEmoji)
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, CustomEmoji)
      end
    end
  end
end
