# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:receiver)       { Fabricate(:user) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender, text: 'The body of the foreign status') }
  let(:own_status)     { Fabricate(:status, account: receiver.account, text: 'The body of the own status') }

  describe 'mention' do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: mention) }
    let(:mail) { prepared_mailer_for(receiver.account).mention }

    include_examples 'localized subject', 'notification_mailer.mention.subject', name: 'bob'

    it 'renders the headers' do
      expect(mail.subject).to eq('You were mentioned by bob')
      expect(mail[:to].value).to eq("#{receiver.account.username} <#{receiver.email}>")
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

    it 'renders the headers' do
      expect(mail.subject).to eq('bob is now following you')
      expect(mail[:to].value).to eq("#{receiver.account.username} <#{receiver.email}>")
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

    it 'renders the headers' do
      expect(mail.subject).to eq('bob favorited your post')
      expect(mail[:to].value).to eq("#{receiver.account.username} <#{receiver.email}>")
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

    it 'renders the headers' do
      expect(mail.subject).to eq('bob boosted your post')
      expect(mail[:to].value).to eq("#{receiver.account.username} <#{receiver.email}>")
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

    it 'renders the headers' do
      expect(mail.subject).to eq('Pending follower: bob')
      expect(mail[:to].value).to eq("#{receiver.account.username} <#{receiver.email}>")
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
