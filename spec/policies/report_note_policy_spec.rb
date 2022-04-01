# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe ReportNotePolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:account) }

  permissions :create? do
    context 'staff?' do
      it 'permits' do
        expect(subject).to permit(admin, ReportNote)
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, ReportNote)
      end
    end
  end

  permissions :destroy? do
    context 'admin?' do
      it 'permit' do
        expect(subject).to permit(admin, ReportNote)
      end
    end

    context 'admin?' do
      context 'owner?' do
        it 'permit' do
          report_note = Fabricate(:report_note, account: john)
          expect(subject).to permit(john, report_note)
        end
      end

      context '!owner?' do
        it 'denies' do
          report_note = Fabricate(:report_note)
          expect(subject).to_not permit(john, report_note)
        end
      end
    end
  end
end
