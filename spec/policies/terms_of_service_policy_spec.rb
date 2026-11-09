# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfServicePolicy do
  subject { described_class }

  let(:admin) { Fabricate.build(:admin_user).account }
  let(:john) { Fabricate.build(:account) }

  permissions :index?, :create? do
    it do
      expect(subject).to permit(admin, TermsOfService)
      expect(subject).to_not permit(john, TermsOfService)
    end
  end

  permissions :update?, :destroy? do
    let(:terms) { Fabricate.build(:terms_of_service, published_at: published) }

    context 'with an unpublished terms' do
      let(:published) { nil }

      it do
        expect(subject).to permit(admin, terms)
        expect(subject).to_not permit(john, terms)
      end
    end

    context 'with a published terms' do
      let(:published) { 5.days.ago }

      it do
        expect(subject).to_not permit(admin, terms)
        expect(subject).to_not permit(john, terms)
      end
    end
  end

  permissions :distribute? do
    let(:terms) { Fabricate.build(:terms_of_service, published_at: published, notification_sent_at: notification) }

    context 'with notification already sent' do
      let(:notification) { 3.days.ago }

      context 'with published true' do
        let(:published) { 5.days.ago }

        it do
          expect(subject).to_not permit(admin, terms)
          expect(subject).to_not permit(john, terms)
        end
      end

      context 'with published false' do
        let(:published) { nil }

        it do
          expect(subject).to_not permit(admin, terms)
          expect(subject).to_not permit(john, terms)
        end
      end
    end

    context 'with notification not yet sent' do
      let(:notification) { nil }

      context 'with published true' do
        let(:published) { 5.days.ago }

        it do
          expect(subject).to permit(admin, terms)
          expect(subject).to_not permit(john, terms)
        end
      end

      context 'with published false' do
        let(:published) { nil }

        it do
          expect(subject).to_not permit(admin, terms)
          expect(subject).to_not permit(john, terms)
        end
      end
    end
  end
end
