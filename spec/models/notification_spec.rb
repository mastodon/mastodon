# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  describe '#target_status' do
    let(:notification) { Fabricate(:notification, activity: activity) }
    let(:status)       { Fabricate(:status) }
    let(:reblog)       { Fabricate(:status, reblog: status) }
    let(:favourite)    { Fabricate(:favourite, status: status) }
    let(:mention)      { Fabricate(:mention, status: status) }

    context 'when Activity is reblog' do
      let(:activity) { reblog }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end

    context 'when Activity is favourite' do
      let(:type)     { :favourite }
      let(:activity) { favourite }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end

    context 'when Activity is mention' do
      let(:activity) { mention }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end
  end

  describe '#type' do
    it 'returns :reblog for a Status' do
      notification = described_class.new(activity: Status.new)
      expect(notification.type).to eq :reblog
    end

    it 'returns :mention for a Mention' do
      notification = described_class.new(activity: Mention.new)
      expect(notification.type).to eq :mention
    end

    it 'returns :favourite for a Favourite' do
      notification = described_class.new(activity: Favourite.new)
      expect(notification.type).to eq :favourite
    end

    it 'returns :follow for a Follow' do
      notification = described_class.new(activity: Follow.new)
      expect(notification.type).to eq :follow
    end
  end

  describe 'Setting account from activity_type' do
    context 'when activity_type is a Status' do
      it 'sets the notification from_account correctly' do
        status = Fabricate(:status)

        notification = Fabricate.build(:notification, activity_type: 'Status', activity: status)

        expect(notification.from_account).to eq(status.account)
      end
    end

    context 'when activity_type is a Follow' do
      it 'sets the notification from_account correctly' do
        follow = Fabricate(:follow)

        notification = Fabricate.build(:notification, activity_type: 'Follow', activity: follow)

        expect(notification.from_account).to eq(follow.account)
      end
    end

    context 'when activity_type is a Favourite' do
      it 'sets the notification from_account correctly' do
        favourite = Fabricate(:favourite)

        notification = Fabricate.build(:notification, activity_type: 'Favourite', activity: favourite)

        expect(notification.from_account).to eq(favourite.account)
      end
    end

    context 'when activity_type is a FollowRequest' do
      it 'sets the notification from_account correctly' do
        follow_request = Fabricate(:follow_request)

        notification = Fabricate.build(:notification, activity_type: 'FollowRequest', activity: follow_request)

        expect(notification.from_account).to eq(follow_request.account)
      end
    end

    context 'when activity_type is a Poll' do
      it 'sets the notification from_account correctly' do
        poll = Fabricate(:poll)

        notification = Fabricate.build(:notification, activity_type: 'Poll', activity: poll)

        expect(notification.from_account).to eq(poll.account)
      end
    end

    context 'when activity_type is a Report' do
      it 'sets the notification from_account correctly' do
        report = Fabricate(:report)

        notification = Fabricate.build(:notification, activity_type: 'Report', activity: report)

        expect(notification.from_account).to eq(report.account)
      end
    end

    context 'when activity_type is a Mention' do
      it 'sets the notification from_account correctly' do
        mention = Fabricate(:mention)

        notification = Fabricate.build(:notification, activity_type: 'Mention', activity: mention)

        expect(notification.from_account).to eq(mention.status.account)
      end
    end

    context 'when activity_type is an Account' do
      it 'sets the notification from_account correctly' do
        account = Fabricate(:account)

        notification = Fabricate.build(:notification, activity_type: 'Account', account: account)

        expect(notification.account).to eq(account)
      end
    end

    context 'when activity_type is an AccountWarning' do
      it 'sets the notification from_account to the recipient of the notification' do
        account = Fabricate(:account)
        account_warning = Fabricate(:account_warning, target_account: account)

        notification = Fabricate.build(:notification, activity_type: 'AccountWarning', activity: account_warning, account: account)

        expect(notification.from_account).to eq(account)
      end
    end
  end

  describe '.paginate_groups_by_max_id' do
    let(:account) { Fabricate(:account) }

    let!(:notifications) do
      ['group-1', 'group-1', nil, 'group-2', nil, 'group-1', 'group-2', 'group-1']
        .map { |group_key| Fabricate(:notification, account: account, group_key: group_key) }
    end

    context 'without since_id or max_id' do
      it 'returns the most recent notifications, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_max_id(4).pluck(:id))
          .to eq [notifications[7], notifications[6], notifications[4], notifications[2]].pluck(:id)
      end
    end

    context 'with since_id' do
      it 'returns the most recent notifications, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_max_id(4, since_id: notifications[4].id).pluck(:id))
          .to eq [notifications[7], notifications[6]].pluck(:id)
      end
    end

    context 'with max_id' do
      it 'returns the most recent notifications after max_id, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_max_id(4, max_id: notifications[7].id).pluck(:id))
          .to eq [notifications[6], notifications[5], notifications[4], notifications[2]].pluck(:id)
      end
    end
  end

  describe '.paginate_groups_by_min_id' do
    let(:account) { Fabricate(:account) }

    let!(:notifications) do
      ['group-1', 'group-1', nil, 'group-2', nil, 'group-1', 'group-2', 'group-1']
        .map { |group_key| Fabricate(:notification, account: account, group_key: group_key) }
    end

    context 'without min_id or max_id' do
      it 'returns the oldest notifications, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_min_id(4).pluck(:id))
          .to eq [notifications[0], notifications[2], notifications[3], notifications[4]].pluck(:id)
      end
    end

    context 'with max_id' do
      it 'returns the oldest notifications, stopping at max_id, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_min_id(4, max_id: notifications[4].id).pluck(:id))
          .to eq [notifications[0], notifications[2], notifications[3]].pluck(:id)
      end
    end

    context 'with min_id' do
      it 'returns the most oldest notifications after min_id, only keeping one notification per group' do
        expect(described_class.without_suspended.paginate_groups_by_min_id(4, min_id: notifications[0].id).pluck(:id))
          .to eq [notifications[1], notifications[2], notifications[3], notifications[4]].pluck(:id)
      end
    end
  end

  describe '.preload_cache_collection_target_statuses' do
    subject do
      described_class.preload_cache_collection_target_statuses(notifications) do |target_statuses|
        # preload account for testing instead of using cache_collection
        Status.preload(:account).where(id: target_statuses.map(&:id))
      end
    end

    context 'when notifications are empty' do
      let(:notifications) { [] }

      it 'returns []' do
        expect(subject).to eq []
      end
    end

    context 'when notifications are present' do
      before do
        notifications.each(&:reload)
      end

      let(:mention) { Fabricate(:mention) }
      let(:status) { Fabricate(:status) }
      let(:reblog) { Fabricate(:status, reblog: Fabricate(:status)) }
      let(:follow) { Fabricate(:follow) }
      let(:follow_request) { Fabricate(:follow_request) }
      let(:favourite) { Fabricate(:favourite) }
      let(:poll) { Fabricate(:poll) }

      let(:notifications) do
        [
          Fabricate(:notification, type: :mention, activity: mention),
          Fabricate(:notification, type: :status, activity: status),
          Fabricate(:notification, type: :reblog, activity: reblog),
          Fabricate(:notification, type: :follow, activity: follow),
          Fabricate(:notification, type: :follow_request, activity: follow_request),
          Fabricate(:notification, type: :favourite, activity: favourite),
          Fabricate(:notification, type: :poll, activity: poll),
        ]
      end

      context 'with a preloaded target status and a cached status' do
        it 'preloads association records and replaces association records' do
          expect(subject)
            .to contain_exactly(
              mention_attributes,
              status_attributes,
              reblog_attributes,
              follow_attributes,
              follow_request_attributes,
              favourite_attributes,
              poll_attributes
            )
        end

        def mention_attributes
          have_attributes(
            type: :mention,
            target_status: eq(mention.status).and(have_loaded_association(:account)),
            mention: have_loaded_association(:status)
          ).and(have_loaded_association(:mention))
        end

        def status_attributes
          have_attributes(
            type: :status,
            target_status: eq(status).and(have_loaded_association(:account))
          ).and(have_loaded_association(:status))
        end

        def reblog_attributes
          have_attributes(
            type: :reblog,
            status: have_loaded_association(:reblog),
            target_status: eq(reblog.reblog).and(have_loaded_association(:account))
          ).and(have_loaded_association(:status))
        end

        def follow_attributes
          have_attributes(
            type: :follow,
            target_status: be_nil
          )
        end

        def follow_request_attributes
          have_attributes(
            type: :follow_request,
            target_status: be_nil
          )
        end

        def favourite_attributes
          have_attributes(
            type: :favourite,
            favourite: have_loaded_association(:status),
            target_status: eq(favourite.status).and(have_loaded_association(:account))
          ).and(have_loaded_association(:favourite))
        end

        def poll_attributes
          have_attributes(
            type: :poll,
            poll: have_loaded_association(:status),
            target_status: eq(poll.status).and(have_loaded_association(:account))
          ).and(have_loaded_association(:poll))
        end
      end
    end
  end
end

RSpec::Matchers.define :have_loaded_association do |association|
  match do |record|
    record.association(association).loaded?
  end

  failure_message do |record|
    "expected #{record} to have loaded association #{association} but it did not."
  end
end
