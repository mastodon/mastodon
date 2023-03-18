# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockDomainService, type: :service do
  subject { described_class.new }

  let!(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let!(:bad_status1) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let!(:bad_status2) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let!(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: bad_status2, file: attachment_fixture('attachment.jpg')) }
  let!(:already_banned_account) { Fabricate(:account, username: 'badguy', domain: 'evil.org', suspended: true, silenced: true) }

  describe 'for a suspension' do
    before do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :suspend))
    end

    it 'creates a domain block' do
      expect(DomainBlock.blocked?('evil.org')).to be true
    end

    it 'removes remote accounts from that domain' do
      expect(Account.find_remote('badguy666', 'evil.org').suspended?).to be true
    end

    it 'records suspension date appropriately' do
      expect(Account.find_remote('badguy666', 'evil.org').suspended_at).to eq DomainBlock.find_by(domain: 'evil.org').created_at
    end

    it 'keeps already-banned accounts banned' do
      expect(Account.find_remote('badguy', 'evil.org').suspended?).to be true
    end

    it 'does not overwrite suspension date of already-banned accounts' do
      expect(Account.find_remote('badguy', 'evil.org').suspended_at).to_not eq DomainBlock.find_by(domain: 'evil.org').created_at
    end

    it 'removes the remote accounts\'s statuses and media attachments' do
      expect { bad_status1.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { bad_status2.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { bad_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  describe 'for a silence with reject media' do
    before do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :silence, reject_media: true))
    end

    it 'does not create a domain block' do
      expect(DomainBlock.blocked?('evil.org')).to be false
    end

    it 'silences remote accounts from that domain' do
      expect(Account.find_remote('badguy666', 'evil.org').silenced?).to be true
    end

    it 'records suspension date appropriately' do
      expect(Account.find_remote('badguy666', 'evil.org').silenced_at).to eq DomainBlock.find_by(domain: 'evil.org').created_at
    end

    it 'keeps already-banned accounts banned' do
      expect(Account.find_remote('badguy', 'evil.org').silenced?).to be true
    end

    it 'does not overwrite suspension date of already-banned accounts' do
      expect(Account.find_remote('badguy', 'evil.org').silenced_at).to_not eq DomainBlock.find_by(domain: 'evil.org').created_at
    end

    it 'leaves the domains status and attachments, but clears media' do
      expect { bad_status1.reload }.to_not raise_error
      expect { bad_status2.reload }.to_not raise_error
      expect { bad_attachment.reload }.to_not raise_error
      expect(bad_attachment.file.exists?).to be false
    end
  end
end
