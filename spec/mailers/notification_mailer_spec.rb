# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:receiver)       { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender, text: 'The body of the foreign status') }
  let(:own_status)     { Fabricate(:status, account: receiver.account, text: 'The body of the own status') }

  shared_examples 'standard headers' do |type|
    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_header('To', "#{receiver.account.username} <#{receiver.email}>"))
        .and(have_header('List-ID', "<#{type}.alice.cb6e6126.ngrok.io>"))
        .and(have_header('List-Unsubscribe', %r{<https://cb6e6126.ngrok.io/unsubscribe\?token=.+>}))
        .and(have_header('List-Unsubscribe', /&type=#{type}/))
        .and(have_header('List-Unsubscribe-Post', 'List-Unsubscribe=One-Click'))
        .and(deliver_to("#{receiver.account.username} <#{receiver.email}>"))
        .and(deliver_from('notifications@localhost'))
    end
  end

  shared_examples 'thread headers' do
    it 'renders the email with conversation thread headers' do
      conversation_header_regex = /<conversation-\d+.\d\d\d\d-\d\d-\d\d@cb6e6126.ngrok.io>/
      expect(mail)
        .to be_present
        .and(have_header('In-Reply-To', conversation_header_regex))
        .and(have_header('References', conversation_header_regex))
    end
  end

  describe 'mention' do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: mention) }
    let(:mail) { prepared_mailer_for(receiver.account).mention }

    include_examples 'localized subject', 'notification_mailer.mention.subject', name: 'bob'
    include_examples 'standard headers', 'mention'
    include_examples 'thread headers'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('You were mentioned by bob'))
        .and(have_body_text('You were mentioned by bob'))
        .and(have_body_text('The body of the foreign status'))
    end
  end

  describe 'follow' do
    let(:follow) { sender.follow!(receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow) }
    let(:mail) { prepared_mailer_for(receiver.account).follow }

    include_examples 'localized subject', 'notification_mailer.follow.subject', name: 'bob'
    include_examples 'standard headers', 'follow'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob is now following you'))
        .and(have_body_text('bob is now following you'))
    end
  end

  describe 'favourite' do
    let(:favourite) { Favourite.create!(account: sender, status: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: favourite) }
    let(:mail) { prepared_mailer_for(own_status.account).favourite }

    include_examples 'localized subject', 'notification_mailer.favourite.subject', name: 'bob'
    include_examples 'standard headers', 'favourite'
    include_examples 'thread headers'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob favorited your post'))
        .and(have_body_text('Your post was favorited by bob'))
        .and(have_body_text('The body of the own status'))
    end
  end

  describe 'reblog' do
    let(:reblog) { Status.create!(account: sender, reblog: own_status) }
    let(:notification) { Notification.create!(account: receiver.account, activity: reblog) }
    let(:mail) { prepared_mailer_for(own_status.account).reblog }

    include_examples 'localized subject', 'notification_mailer.reblog.subject', name: 'bob'
    include_examples 'standard headers', 'reblog'
    include_examples 'thread headers'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('bob boosted your post'))
        .and(have_body_text('Your post was boosted by bob'))
        .and(have_body_text('The body of the own status'))
    end
  end

  describe 'follow_request' do
    let(:follow_request) { Fabricate(:follow_request, account: sender, target_account: receiver.account) }
    let(:notification) { Notification.create!(account: receiver.account, activity: follow_request) }
    let(:mail) { prepared_mailer_for(receiver.account).follow_request }

    include_examples 'localized subject', 'notification_mailer.follow_request.subject', name: 'bob'
    include_examples 'standard headers', 'follow_request'

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(have_subject('Pending follower: bob'))
        .and(have_body_text('bob has requested to follow you'))
    end
  end

  private

  def prepared_mailer_for(recipient)
    described_class.with(recipient: recipient, notification: notification)
  end
end
