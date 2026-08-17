# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :create?, :update?, :destroy? do
    context 'with an admin' do
      it { is_expected.to permit(admin, Announcement) }
    end

    context 'with a non-admin' do
      it { is_expected.to_not permit(john, Announcement) }
    end
  end

  permissions :distribute? do
    let(:announcement) { Fabricate :announcement }

    context 'with non admin role' do
      it { is_expected.to_not permit(john, announcement) }
    end

    context 'with admin role' do
      context 'with unpublished announcement' do
        let(:announcement) { Fabricate :announcement, published: false, scheduled_at: 5.days.from_now }

        it { is_expected.to_not permit(admin, announcement) }
      end

      context 'with published already sent announcement' do
        let(:announcement) { Fabricate :announcement, notification_sent_at: 3.days.ago }

        it { is_expected.to_not permit(admin, announcement) }
      end

      context 'with published not sent announcement' do
        let(:announcement) { Fabricate :announcement }

        it { is_expected.to permit(admin, announcement) }
      end
    end
  end
end
