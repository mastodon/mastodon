# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe BackupPolicy do
  let(:subject) { described_class }
  let(:john)    { Fabricate(:user).account }

  permissions :create? do
    context 'not user_signed_in?' do
      it 'denies' do
        expect(subject).to_not permit(nil, Backup)
      end
    end

    context 'user_signed_in?' do
      context 'no backups' do
        it 'permits' do
          expect(subject).to permit(john, Backup)
        end
      end

      context 'backups are too old' do
        it 'permits' do
          travel(-8.days) do
            Fabricate(:backup, user: john.user)
          end

          expect(subject).to permit(john, Backup)
        end
      end

      context 'backups are newer' do
        it 'denies' do
          travel(-3.days) do
            Fabricate(:backup, user: john.user)
          end

          expect(subject).to_not permit(john, Backup)
        end
      end
    end
  end
end
