require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:receiver)       { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender) }
  let(:own_status)     { Fabricate(:status, account: receiver.account) }

  describe "mention" do
    let(:mention) { Mention.create!(account: receiver.account, status: foreign_status) }
    let(:mail) { NotificationMailer.mention(receiver.account, Notification.create!(account: receiver.account, activity: mention)) }

    it "renders the headers" do
      expect(mail.subject).to eq("You were mentioned by bob")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("You were mentioned by bob")
    end
  end

  describe "follow" do
    let(:follow) { sender.follow!(receiver.account) }
    let(:mail) { NotificationMailer.follow(receiver.account, Notification.create!(account: receiver.account, activity: follow)) }

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

    it "renders the headers" do
      expect(mail.subject).to eq("bob favourited your status")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your status was favourited by bob")
    end
  end

  describe "reblog" do
    let(:reblog) { Status.create!(account: sender, reblog: own_status) }
    let(:mail) { NotificationMailer.reblog(own_status.account, Notification.create!(account: receiver.account, activity: reblog)) }

    it "renders the headers" do
      expect(mail.subject).to eq("bob boosted your status")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your status was boosted by bob")
    end
  end

  describe 'follow_request' do
    let(:follow_request) { Fabricate(:follow_request, account: sender, target_account: receiver.account) }
    let(:mail) { NotificationMailer.follow_request(receiver.account, Notification.create!(account: receiver.account, activity: follow_request)) }

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
      mention = Fabricate(:mention, account: receiver.account)
      Fabricate(:notification, account: receiver.account, activity: mention)
    end
    let(:mail) { NotificationMailer.digest(receiver.account, since: 5.days.ago) }

    it 'renders the headers' do
      expect(mail.subject).to match('notification since your last')
      expect(mail.to).to eq([receiver.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('brief summary')
    end
  end
end
