# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::NotificationGroupSerializer do
  subject do
    serialized_record_json(
      notification_group,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
        supported_notification_types: [],
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:notification_group) { NotificationGroup.new pagination_data: { latest_notification_at: 3.days.ago }, notification: Fabricate(:notification), sample_accounts: [] }

  context 'when latest_page_notification_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'latest_page_notification_at' => match_api_datetime_format
        )
    end
  end

  shared_examples 'with fallback notifications' do |type, fabricators|
    let(:activities) { fabricators.map { |fabricator| Fabricate(fabricator) } }
    let(:notifications) { activities.map { |activity| Fabricate(:notification, type:, activity:, account: current_user.account) } }
    let(:notification_group) { NotificationGroup.new(notification: notifications.last, sample_accounts: notifications.map(&:from_account)) }

    it 'renders correctly' do
      expect(subject)
        .to include(
          'type' => type,
          'fallback' => include(
            'title' => anything,
            'summary' => anything
          )
        )
    end
  end

  it_behaves_like 'with fallback notifications', 'severed_relationships', [:account_relationship_severance_event]
  it_behaves_like 'with fallback notifications', 'moderation_warning', [:account_warning]
  it_behaves_like 'with fallback notifications', 'admin.report', [:report]
  it_behaves_like 'with fallback notifications', 'admin.report', [:report, :report]
  it_behaves_like 'with fallback notifications', 'added_to_collection', [:collection_item]
  it_behaves_like 'with fallback notifications', 'collection_update', [:collection]
end
