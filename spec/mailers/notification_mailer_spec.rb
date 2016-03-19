require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:receiver)       { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:sender)         { Fabricate(:account, username: 'bob') }
  let(:foreign_status) { Fabricate(:status, account: sender) }
  let(:own_status)     { Fabricate(:status, account: receiver.account) }

  describe "mention" do
    let(:mail) { NotificationMailer.mention(receiver.account, foreign_status) }

    it "renders the headers" do
      expect(mail.subject).to eq("You were mentioned by bob")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("You were mentioned by bob")
    end
  end

  describe "follow" do
    let(:mail) { NotificationMailer.follow(receiver.account, sender) }

    it "renders the headers" do
      expect(mail.subject).to eq("bob is now following you")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("bob is now following you")
    end
  end

  describe "favourite" do
    let(:mail) { NotificationMailer.favourite(own_status, sender) }

    it "renders the headers" do
      expect(mail.subject).to eq("bob favourited your status")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your status was favourited by bob")
    end
  end

  describe "reblog" do
    let(:mail) { NotificationMailer.reblog(own_status, sender) }

    it "renders the headers" do
      expect(mail.subject).to eq("bob reblogged your status")
      expect(mail.to).to eq([receiver.email])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your status was reblogged by bob")
    end
  end

end
