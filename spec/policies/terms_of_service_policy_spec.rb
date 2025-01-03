# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsOfServicePolicy do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user).account }
  let(:john) { Fabricate(:account) }

  permissions :index?, :create? do
    it { is_expected.to permit(admin, TermsOfService) }
    it { is_expected.to_not permit(john, TermsOfService) }
  end

  permissions :update?, :destroy? do
    let(:terms) { Fabricate(:terms_of_service, published_at: published) }

    context 'with an unpublished terms' do
      let(:published) { nil }

      it { is_expected.to permit(admin, terms) }
      it { is_expected.to_not permit(john, terms) }
    end

    context 'with a published terms' do
      let(:published) { 5.days.ago }

      it { is_expected.to_not permit(admin, terms) }
      it { is_expected.to_not permit(john, terms) }
    end
  end

  permissions :distribute? do
    let(:terms) { Fabricate(:terms_of_service, published_at: published, notification_sent_at: notification) }

    context 'with notification already sent' do
      let(:notification) { 3.days.ago }

      context 'with published true' do
        let(:published) { 5.days.ago }

        it { is_expected.to_not permit(admin, terms) }
        it { is_expected.to_not permit(john, terms) }
      end

      context 'with published false' do
        let(:published) { nil }

        it { is_expected.to_not permit(admin, terms) }
        it { is_expected.to_not permit(john, terms) }
      end
    end

    context 'with notification not yet sent' do
      let(:notification) { nil }

      context 'with published true' do
        let(:published) { 5.days.ago }

        it { is_expected.to permit(admin, terms) }
        it { is_expected.to_not permit(john, terms) }
      end

      context 'with published false' do
        let(:published) { nil }

        it { is_expected.to_not permit(admin, terms) }
        it { is_expected.to_not permit(john, terms) }
      end
    end
  end
end
