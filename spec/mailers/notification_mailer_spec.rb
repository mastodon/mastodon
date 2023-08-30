# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:receiver)       { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender, text: 'The body of the foreign status') }
  let(:own_status)     { Fabricate(:status, account: receiver.account, text: 'The body of the own status') }

  shared_examples 'headers' do |type, thread|
    it 'renders the to and from headers' do
      expect(mail[:to].value).to eq "#{receiver.account.username} <#{receiver.email}>"
      expect(mail.from).to eq ['notifications@localhost']
    end

    it 'renders the list headers' do
      expect(mail['List-ID'].value).to eq "<#{type}.alice.cb6e6126.ngrok.io>"
      expect(mail['List-Unsubscribe'].value).to match(%r{<https://cb6e6126.ngrok.io/unsubscribe\?token=.+>})
      expect(mail['List-Unsubscribe'].value).to match("&type=#{type}")
      expect(mail['List-Unsubscribe-Post'].value).to eq 'List-Unsubscribe=One-Click'
    end

    if thread
      it 'renders the thread headers' do
        expect(mail['In-Reply-To'].value).to match(/<conversation-\d+.\d\d\d\d-\d\d-\d\d@cb6e6126.ngrok.io>/)
        expect(mail['References'].value).to match(/<conversation-\d+.\d\d\d\d-\d\d-\d\d@cb6e6126.ngrok.io>/)
      end
    end
  end

  describe 'mention' do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: mention) }
    let(:mail) { prepared_mailer_for(receiver.account).mention }

    include_examples 'localized subject', 'notification_mailer.mention.subject', name: 'bob'
    include_examples 'headers', 'mention', true

    it 'renders the subject' do
      expect(mail.subject).to eq('You were mentioned by bob')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('You were mentioned by bob')
      expect(mail.body.encoded).to include 'The body of the foreign status'
    end
  end

  describe 'follow' do
    let(:follow) { sender.follow!(receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow) }
    let(:mail) { prepared_mailer_for(receiver.account).follow }

    include_examples 'localized subject', 'notification_mailer.follow.subject', name: 'bob'
    include_examples 'headers', 'follow', false

    it 'renders the subject' do
      expect(mail.subject).to eq('bob is now following you')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('bob is now following you')
    end
  end

  describe 'favourite' do
    let(:favourite) { Favourite.create!(account: sender, status: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: favourite) }
    let(:mail) { prepared_mailer_for(own_status.account).favourite }

    include_examples 'localized subject', 'notification_mailer.favourite.subject', name: 'bob'
    include_examples 'headers', 'favourite', true

    it 'renders the subject' do
      expect(mail.subject).to eq('bob favorited your post')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Your post was favorited by bob')
      expect(mail.body.encoded).to include 'The body of the own status'
    end
  end

  describe 'reblog' do
    let(:reblog) { Status.create!(account: sender, reblog: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: reblog) }
    let(:mail) { prepared_mailer_for(own_status.account).reblog }

    include_examples 'localized subject', 'notification_mailer.reblog.subject', name: 'bob'
    include_examples 'headers', 'reblog', true

    it 'renders the subject' do
      expect(mail.subject).to eq('bob boosted your post')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Your post was boosted by bob')
      expect(mail.body.encoded).to include 'The body of the own status'
    end
  end

  describe 'follow_request' do
    let(:follow_request) { Fabricate(:follow_request, account: sender, target_account: receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow_request) }
    let(:mail) { prepared_mailer_for(receiver.account).follow_request }

    include_examples 'localized subject', 'notification_mailer.follow_request.subject', name: 'bob'
    include_examples 'headers', 'follow_request', false

    it 'renders the subject' do
      expect(mail.subject).to eq('Pending follower: bob')
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('bob has requested to follow you')
    end
  end

  private

  def prepared_mailer_for(recipient)
    described_class.with(recipient: recipient, notification: notification)
  end
end
