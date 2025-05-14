# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  shared_examples 'delivery to non functional user' do
    context 'when user is not functional' do
      before { receiver.update(confirmed_at: nil) }

      it 'does not deliver mail' do
        emails = capture_emails { mail.deliver_now }
        expect(emails).to be_empty
      end
    end
  end

  shared_examples 'delivery without status' do
    context 'when notification target_status is missing' do
      before { allow(notification).to receive(:target_status).and_return(nil) }

      it 'does not deliver mail' do
        emails = capture_emails { mail.deliver_now }
        expect(emails).to be_empty
      end
    end
  end

  let(:receiver)       { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender, text: 'The body of the foreign status') }
  let(:own_status)     { Fabricate(:status, account: receiver.account, text: 'The body of the own status') }

  describe 'mention' do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: mention) }
    let(:mail) { prepared_mailer_for(receiver.account).mention }

    it_behaves_like 'localized subject', 'notification_mailer.mention.subject', name: 'bob'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('You were mentioned by bob'))
        .and(have_body_text('You were mentioned by bob'))
        .and(have_body_text('The body of the foreign status'))
        .and have_thread_headers
        .and have_standard_headers('mention').for(receiver)
    end

    it_behaves_like 'delivery to non functional user'
    it_behaves_like 'delivery without status'
  end

  describe 'follow' do
    let(:follow) { sender.follow!(receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow) }
    let(:mail) { prepared_mailer_for(receiver.account).follow }

    it_behaves_like 'localized subject', 'notification_mailer.follow.subject', name: 'bob'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob is now following you'))
        .and(have_body_text('bob is now following you'))
        .and have_standard_headers('follow').for(receiver)
    end

    it_behaves_like 'delivery to non functional user'
  end

  describe 'favourite' do
    let(:favourite) { Favourite.create!(account: sender, status: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: favourite) }
    let(:mail) { prepared_mailer_for(own_status.account).favourite }

    it_behaves_like 'localized subject', 'notification_mailer.favourite.subject', name: 'bob'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob favorited your post'))
        .and(have_body_text('Your post was favorited by bob'))
        .and(have_body_text('The body of the own status'))
        .and have_thread_headers
        .and have_standard_headers('favourite').for(receiver)
    end

    it_behaves_like 'delivery to non functional user'
    it_behaves_like 'delivery without status'
  end

  describe 'reblog' do
    let(:reblog) { Status.create!(account: sender, reblog: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: reblog) }
    let(:mail) { prepared_mailer_for(own_status.account).reblog }

    it_behaves_like 'localized subject', 'notification_mailer.reblog.subject', name: 'bob'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob boosted your post'))
        .and(have_body_text('Your post was boosted by bob'))
        .and(have_body_text('The body of the own status'))
        .and have_thread_headers
        .and have_standard_headers('reblog').for(receiver)
    end

    it_behaves_like 'delivery to non functional user'
    it_behaves_like 'delivery without status'
  end

  describe 'follow_request' do
    let(:follow_request) { Fabricate(:follow_request, account: sender, target_account: receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow_request) }
    let(:mail) { prepared_mailer_for(receiver.account).follow_request }

    it_behaves_like 'localized subject', 'notification_mailer.follow_request.subject', name: 'bob'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('Pending follower: bob'))
        .and(have_body_text('bob has requested to follow you'))
        .and have_standard_headers('follow_request').for(receiver)
    end

    it_behaves_like 'delivery to non functional user'
  end

  private

  def prepared_mailer_for(recipient)
    described_class.with(recipient: recipient, notification: notification)
  end
end
