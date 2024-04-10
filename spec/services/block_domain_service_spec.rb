# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockDomainService do
  subject { described_class.new }

  let(:local_account) { Fabricate(:account) }
  let(:bystander) { Fabricate(:account, domain: 'evil.org') }
  let!(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let!(:bad_status_plain) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let!(:bad_status_with_attachment) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let!(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: bad_status_with_attachment, file: attachment_fixture('attachment.jpg')) }
  let!(:already_banned_account) { Fabricate(:account, username: 'badguy', domain: 'evil.org', suspended: true, silenced: true) }

  describe 'for a suspension' do
    before do
      local_account.follow!(bad_account)
      bystander.follow!(local_account)
    end

    it 'creates a domain block, suspends remote accounts with appropriate suspension date, records severed relationships and sends notification', :aggregate_failures do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :suspend))

      expect(DomainBlock.blocked?('evil.org')).to be true

      # Suspends account with appropriate suspension date
      expect(bad_account.reload.suspended?).to be true
      expect(bad_account.reload.suspended_at).to eq DomainBlock.find_by(domain: 'evil.org').created_at

      # Keep already-suspended account without updating the suspension date
      expect(already_banned_account.reload.suspended?).to be true
      expect(already_banned_account.reload.suspended_at).to_not eq DomainBlock.find_by(domain: 'evil.org').created_at

      # Removes content
      expect { bad_status_plain.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { bad_status_with_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { bad_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound

      # Records severed relationships
      severed_relationships = local_account.severed_relationships.to_a
      expect(severed_relationships.count).to eq 2
      expect(severed_relationships[0].relationship_severance_event).to eq severed_relationships[1].relationship_severance_event
      expect(severed_relationships.map { |rel| [rel.account, rel.target_account] }).to contain_exactly([bystander, local_account], [local_account, bad_account])

      # Sends severed relationships notification
      expect(LocalNotificationWorker).to have_enqueued_sidekiq_job(local_account.id, anything, 'AccountRelationshipSeveranceEvent', 'severed_relationships')
    end
  end

  describe 'for a silence with reject media' do
    it 'does not mark the domain as blocked, but silences accounts with an appropriate silencing date, clears media', :aggregate_failures, :sidekiq_inline do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :silence, reject_media: true))

      expect(DomainBlock.blocked?('evil.org')).to be false

      # Silences account with appropriate silecing date
      expect(bad_account.reload.silenced?).to be true
      expect(bad_account.reload.silenced_at).to eq DomainBlock.find_by(domain: 'evil.org').created_at

      # Keeps already-silenced accounts without updating the silecing date
      expect(already_banned_account.reload.silenced?).to be true
      expect(already_banned_account.reload.silenced_at).to_not eq DomainBlock.find_by(domain: 'evil.org').created_at

      # Leaves posts but clears media
      expect { bad_status_plain.reload }.to_not raise_error
      expect { bad_status_with_attachment.reload }.to_not raise_error
      expect { bad_attachment.reload }.to_not raise_error
      expect(bad_attachment.file.exists?).to be false
    end
  end
end
