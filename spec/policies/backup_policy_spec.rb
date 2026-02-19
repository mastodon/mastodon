# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackupPolicy do
  subject { described_class }

  let(:john) { Fabricate(:account) }

  permissions :create? do
    context 'when not user_signed_in?' do
      it 'denies' do
        expect(subject).to_not permit(nil, Backup)
      end
    end

    context 'when user_signed_in?' do
      context 'with no backups' do
        it 'permits' do
          expect(subject).to permit(john, Backup)
        end
      end

      context 'when backups are too old' do
        it 'permits' do
          travel(-before_time) do
            Fabricate(:backup, user: john.user)
          end

          expect(subject).to permit(john, Backup)
        end

        def before_time
          described_class::MIN_AGE + 2.days
        end
      end

      context 'when backups are newer' do
        it 'denies' do
          travel(-within_time) do
            Fabricate(:backup, user: john.user)
          end

          expect(subject).to_not permit(john, Backup)
        end

        def within_time
          described_class::MIN_AGE - 2.days
        end
      end
    end
  end
end
