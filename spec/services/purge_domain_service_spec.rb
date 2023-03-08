# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeDomainService, type: :service do
  subject { PurgeDomainService.new }

  let!(:old_account) { Fabricate(:account, domain: 'obsolete.org') }
  let!(:old_status1) { Fabricate(:status, account: old_account) }
  let!(:old_status2) { Fabricate(:status, account: old_account) }
  let!(:old_attachment) { Fabricate(:media_attachment, account: old_account, status: old_status2, file: attachment_fixture('attachment.jpg')) }

  describe 'for a suspension' do
    before do
      subject.call('obsolete.org')
    end

    it 'removes the remote accounts\'s statuses and media attachments' do
      expect { old_account.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_status1.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_status2.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
    end

    it 'refreshes instances view' do
      expect(Instance.where(domain: 'obsolete.org').exists?).to be false
    end
  end
end
