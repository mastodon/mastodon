require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:receiver)       { Fabricate(:user) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender, text: 'The body of the foreign status') }
  let(:own_status)     { Fabricate(:status, account: receiver.account, text: 'The body of the own status') }

  shared_examples 'localized subject' do |*args, **kwrest|
    it 'renders subject localized for the locale of the receiver' do
      locale = %i(de en).sample
      receiver.update!(locale: locale)
      expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: locale))
    end

    it 'renders subject localized for the default locale if the locale of the receiver is unavailable' do
      receiver.update!(locale: nil)
      expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: I18n.default_locale))
    end
  end

  describe "mention" do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:mail) { NotificationMailer.mention(receiver.account, Notification.create!(account: receiver.account, activity: mention)) }

    include_examples 'localized subject', 'notification_mailer.mention.subject', name: 'bob'

    it "renders the headers" do
      expect(mail.subject).to eq("You were mentioned by bob")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("You were mentioned by bob")
      expect(mail.body.encoded).to include 'The body of the foreign status'
    end
  end

  describe "follow" do
    let(:follow) { sender.follow!(receiver.account) }
    let(:mail) { NotificationMailer.follow(receiver.account, Notification.create!(account: receiver.account, activity: follow)) }

    include_examples 'localized subject', 'notification_mailer.follow.subject', name: 'bob'

    it "renders the headers" do
      expect(mail.subject).to eq("bob is now following you")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("bob is now following you")
    end
  end

  describe "favourite" do
    let(:favourite) { Favourite.create!(account: sender, status: own_status) }
    let(:mail) { NotificationMailer.favourite(own_status.account, Notification.create!(account: receiver.account, activity: favourite)) }

    include_examples 'localized subject', 'notification_mailer.favourite.subject', name: 'bob'

    it "renders the headers" do
      expect(mail.subject).to eq("bob favourited your post")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your post was favourited by bob")
      expect(mail.body.encoded).to include 'The body of the own status'
    end
  end

  describe "reblog" do
    let(:reblog) { Status.create!(account: sender, reblog: own_status) }
    let(:mail) { NotificationMailer.reblog(own_status.account, Notification.create!(account: receiver.account, activity: reblog)) }

    include_examples 'localized subject', 'notification_mailer.reblog.subject', name: 'bob'

    it "renders the headers" do
      expect(mail.subject).to eq("bob boosted your post")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your post was boosted by bob")
      expect(mail.body.encoded).to include 'The body of the own status'
    end
  end

  describe 'follow_request' do
    let(:follow_request) { Fabricate(:follow_request, account: sender, target_account: receiver.account) }
    let(:mail) { NotificationMailer.follow_request(receiver.account, Notification.create!(account: receiver.account, activity: follow_request)) }

    include_examples 'localized subject', 'notification_mailer.follow_request.subject', name: 'bob'

    it 'renders the headers' do
      expect(mail.subject).to eq('Pending follower: bob')
      expect(mail.to).to eq([receiver.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("bob has requested to follow you")
    end
  end

  describe 'digest' do
    before do
      mention = Fabricate(:mention, account: receiver.account, status: foreign_status)
      Fabricate(:notification, account: receiver.account, activity: mention)
      sender.follow!(receiver.account)
    end

    context do
      let!(:mail) { NotificationMailer.digest(receiver.account, since: 5.days.ago) }

      include_examples 'localized subject', 'notification_mailer.digest.subject', count: 1, name: 'bob'

      it 'renders the headers' do
        expect(mail.subject).to match('notification since your last')
        expect(mail.to).to eq([receiver.email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('brief summary')
        expect(mail.body.encoded).to include 'The body of the foreign status'
        expect(mail.body.encoded).to include sender.username
      end
    end

    it 'includes activities since the receiver last signed in' do
      receiver.update!(last_emailed_at: nil, current_sign_in_at: '2000-03-01T00:00:00Z')
      mail = NotificationMailer.digest(receiver.account)
      expect(mail.body.encoded).to include 'Mar 01, 2000, 00:00'
    end
  end
end
