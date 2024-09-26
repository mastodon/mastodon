# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyService do
  subject { described_class.new.call(recipient, type, activity) }

  let(:user) { Fabricate(:user) }
  let(:recipient) { user.account }
  let(:sender) { Fabricate(:account, domain: 'example.com') }
  let(:activity) { Fabricate(:follow, account: sender, target_account: recipient) }
  let(:type) { :follow }

  it { expect { subject }.to change(Notification, :count).by(1) }

  it 'does not notify when sender is blocked' do
    recipient.block!(sender)
    expect { subject }.to_not change(Notification, :count)
  end

  it 'does not notify when sender is muted with hide_notifications' do
    recipient.mute!(sender, notifications: true)
    expect { subject }.to_not change(Notification, :count)
  end

  it 'does notify when sender is muted without hide_notifications' do
    recipient.mute!(sender, notifications: false)
    expect { subject }.to change(Notification, :count)
  end

  it 'does not notify when sender\'s domain is blocked' do
    recipient.block_domain!(sender.domain)
    expect { subject }.to_not change(Notification, :count)
  end

  it 'does still notify when sender\'s domain is blocked but sender is followed' do
    recipient.block_domain!(sender.domain)
    recipient.follow!(sender)
    expect { subject }.to change(Notification, :count)
  end

  it 'does not notify when sender is silenced and not followed' do
    sender.silence!
    subject
    expect(Notification.find_by(activity: activity).filtered?).to be true
  end

  it 'does not notify when recipient is suspended' do
    recipient.suspend!
    expect { subject }.to_not change(Notification, :count)
  end

  describe 'reblogs' do
    let(:status)   { Fabricate(:status, account: Fabricate(:account)) }
    let(:activity) { Fabricate(:status, account: sender, reblog: status) }
    let(:type)     { :reblog }

    it 'shows reblogs by default' do
      recipient.follow!(sender)
      expect { subject }.to change(Notification, :count)
    end

    it 'shows reblogs when explicitly enabled' do
      recipient.follow!(sender, reblogs: true)
      expect { subject }.to change(Notification, :count)
    end

    it 'shows reblogs when disabled' do
      recipient.follow!(sender, reblogs: false)
      expect { subject }.to change(Notification, :count)
    end
  end

  context 'with muted and blocked users' do
    let(:asshole)  { Fabricate(:account, username: 'asshole') }
    let(:reply_to) { Fabricate(:status, account: asshole) }
    let(:activity) { Fabricate(:mention, account: recipient, status: Fabricate(:status, account: sender, thread: reply_to)) }
    let(:type)     { :mention }

    it 'does not notify when conversation is muted' do
      recipient.mute_conversation!(activity.status.conversation)
      expect { subject }.to_not change(Notification, :count)
    end

    it 'does not notify when it is a reply to a blocked user' do
      recipient.block!(asshole)
      expect { subject }.to_not change(Notification, :count)
    end
  end

  context 'with sender as recipient' do
    let(:sender) { recipient }

    it 'does not notify when recipient is the sender' do
      expect { subject }.to_not change(Notification, :count)
    end
  end

  describe 'email' do
    before do
      user.settings.update('notification_emails.follow': enabled)
      user.save
    end

    context 'when email notification is enabled' do
      let(:enabled) { true }

      it 'sends email', :inline_jobs do
        emails = capture_emails { subject }

        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: contain_exactly(user.email),
            subject: eq(I18n.t('notification_mailer.follow.subject', name: sender.acct))
          )
      end
    end

    context 'when email notification is disabled' do
      let(:enabled) { false }

      it "doesn't send email" do
        emails = capture_emails { subject }

        expect(emails).to be_empty
      end
    end
  end

  context 'when the blocked sender has a role' do
    let(:sender) { Fabricate(:user, role: sender_role).account }
    let(:activity) { Fabricate(:mention, status: Fabricate(:status, account: sender)) }
    let(:type) { :mention }

    before do
      recipient.block!(sender)
    end

    context 'when the role is a visible moderator' do
      let(:sender_role) { Fabricate(:user_role, highlighted: true, permissions: UserRole::FLAGS[:manage_users]) }

      it 'does notify' do
        expect { subject }.to change(Notification, :count)
      end
    end

    context 'when the role is a non-visible moderator' do
      let(:sender_role) { Fabricate(:user_role, highlighted: false, permissions: UserRole::FLAGS[:manage_users]) }

      it 'does not notify' do
        expect { subject }.to_not change(Notification, :count)
      end
    end

    context 'when the role is a visible non-moderator' do
      let(:sender_role) { Fabricate(:user_role, highlighted: true) }

      it 'does not notify' do
        expect { subject }.to_not change(Notification, :count)
      end
    end
  end

  context 'with filtered notifications' do
    let(:unknown)  { Fabricate(:account, username: 'unknown') }
    let(:status)   { Fabricate(:status, account: unknown) }
    let(:activity) { Fabricate(:mention, account: recipient, status: status) }
    let(:type)     { :mention }

    before do
      Fabricate(:notification_policy, account: recipient, filter_not_following: true)
    end

    it 'creates a filtered notification' do
      expect { subject }.to change(Notification, :count)
      expect(Notification.last).to be_filtered
    end

    context 'when no notification request exists' do
      it 'creates a notification request' do
        expect { subject }.to change(NotificationRequest, :count)
      end
    end

    context 'when a notification request exists' do
      let!(:notification_request) do
        Fabricate(:notification_request, account: recipient, from_account: unknown, last_status: Fabricate(:status, account: unknown))
      end

      it 'updates the existing notification request' do
        expect { subject }.to_not change(NotificationRequest, :count)
        expect(notification_request.reload.last_status).to eq status
      end
    end
  end

  describe NotifyService::DropCondition do
    subject { described_class.new(notification) }

    let(:activity) { Fabricate(:mention, status: Fabricate(:status)) }
    let(:notification) { Fabricate(:notification, type: :mention, activity: activity, from_account: activity.status.account, account: activity.account) }

    describe '#drop' do
      context 'when sender is silenced and recipient has a default policy' do
        before do
          notification.from_account.silence!
        end

        it 'returns false' do
          expect(subject.drop?).to be false
        end
      end

      context 'when sender is silenced and recipient has a policy to ignore silenced accounts' do
        before do
          notification.from_account.silence!
          notification.account.create_notification_policy!(for_limited_accounts: :drop)
        end

        it 'returns true' do
          expect(subject.drop?).to be true
        end
      end

      context 'when sender is new and recipient has a default policy' do
        it 'returns false' do
          expect(subject.drop?).to be false
        end
      end

      context 'when sender is new and recipient has a policy to ignore silenced accounts' do
        before do
          notification.account.create_notification_policy!(for_new_accounts: :drop)
        end

        it 'returns true' do
          expect(subject.drop?).to be true
        end
      end

      context 'when sender is new and followed and recipient has a policy to ignore silenced accounts' do
        before do
          notification.account.create_notification_policy!(for_new_accounts: :drop)
          notification.account.follow!(notification.from_account)
        end

        it 'returns false' do
          expect(subject.drop?).to be false
        end
      end

      context 'when recipient has blocked sender' do
        before do
          notification.account.block!(notification.from_account)
        end

        it 'returns true' do
          expect(subject.drop?).to be true
        end
      end
    end
  end

  describe NotifyService::FilterCondition do
    subject { described_class.new(notification) }

    let(:activity) { Fabricate(:mention, status: Fabricate(:status)) }
    let(:notification) { Fabricate(:notification, type: :mention, activity: activity, from_account: activity.status.account, account: activity.account) }

    describe '#filter?' do
      context 'when sender is silenced' do
        before do
          notification.from_account.silence!
        end

        it 'returns true' do
          expect(subject.filter?).to be true
        end

        context 'when recipient follows sender' do
          before do
            notification.account.follow!(notification.from_account)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end

        context 'when recipient is allowing limited accounts' do
          before do
            notification.account.create_notification_policy!(for_limited_accounts: :accept)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end
      end

      context 'when recipient is filtering not-followed senders' do
        before do
          Fabricate(:notification_policy, account: notification.account, filter_not_following: true)
        end

        it 'returns true' do
          expect(subject.filter?).to be true
        end

        context 'when sender has permission' do
          before do
            Fabricate(:notification_permission, account: notification.account, from_account: notification.from_account)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end

        context 'when sender is followed by recipient' do
          before do
            notification.account.follow!(notification.from_account)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end
      end

      context 'when recipient is filtering not-followers' do
        before do
          Fabricate(:notification_policy, account: notification.account, filter_not_followers: true)
        end

        it 'returns true' do
          expect(subject.filter?).to be true
        end

        context 'when sender has permission' do
          before do
            Fabricate(:notification_permission, account: notification.account, from_account: notification.from_account)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end

        context 'when sender follows recipient' do
          before do
            notification.from_account.follow!(notification.account)
          end

          it 'returns true' do
            expect(subject.filter?).to be true
          end
        end

        context 'when sender follows recipient for longer than 3 days' do
          before do
            follow = notification.from_account.follow!(notification.account)
            follow.update(created_at: 4.days.ago)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end
      end

      context 'when recipient is filtering new accounts' do
        before do
          Fabricate(:notification_policy, account: notification.account, filter_new_accounts: true)
        end

        it 'returns true' do
          expect(subject.filter?).to be true
        end

        context 'when sender has permission' do
          before do
            Fabricate(:notification_permission, account: notification.account, from_account: notification.from_account)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end

        context 'when sender is older than 30 days' do
          before do
            notification.from_account.update(created_at: 31.days.ago)
          end

          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end
      end

      context 'when recipient is not filtering anyone' do
        before do
          Fabricate(:notification_policy, account: notification.account)
        end

        it 'returns false' do
          expect(subject.filter?).to be false
        end
      end

      context 'when recipient is filtering unsolicited private mentions' do
        before do
          Fabricate(:notification_policy, account: notification.account, filter_private_mentions: true)
        end

        context 'when notification is not a private mention' do
          it 'returns false' do
            expect(subject.filter?).to be false
          end
        end

        context 'when notification is a private mention' do
          before do
            notification.target_status.update(visibility: :direct)
          end

          it 'returns true' do
            expect(subject.filter?).to be true
          end

          context 'when the message chain is initiated by recipient, but sender is not mentioned' do
            before do
              original_status = Fabricate(:status, account: notification.account, visibility: :direct)
              notification.target_status.update(thread: original_status)
            end

            it 'returns true' do
              expect(subject.filter?).to be true
            end
          end

          context 'when the message chain is initiated by recipient, and sender is mentioned' do
            before do
              original_status = Fabricate(:status, account: notification.account, visibility: :direct)
              notification.target_status.update(thread: original_status)
              Fabricate(:mention, status: original_status, account: notification.from_account)
            end

            it 'returns false' do
              expect(subject.filter?).to be false
            end
          end

          context 'when the sender is mentioned in an unrelated message chain' do
            before do
              original_status = Fabricate(:status, visibility: :direct)
              intermediary_status = Fabricate(:status, visibility: :direct, thread: original_status)
              notification.target_status.update(thread: intermediary_status)
              Fabricate(:mention, status: original_status, account: notification.from_account)
            end

            it 'returns true' do
              expect(subject.filter?).to be true
            end
          end
        end
      end
    end
  end
end
