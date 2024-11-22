# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportNotePolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :create? do
    context 'when staff?' do
      it 'permits' do
        expect(subject).to permit(admin, ReportNote)
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, ReportNote)
      end
    end
  end

  permissions :destroy? do
    context 'when admin?' do
      it 'permit' do
        report_note = Fabricate(:report_note, account: john)
        expect(subject).to permit(admin, report_note)
      end
    end

    context 'when owner?' do
      it 'permit' do
        report_note = Fabricate(:report_note, account: john)
        expect(subject).to permit(john, report_note)
      end
    end

    context 'with !owner?' do
      it 'denies' do
        report_note = Fabricate(:report_note)
        expect(subject).to_not permit(john, report_note)
      end
    end
  end
end
