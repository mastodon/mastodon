# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeDomainService, type: :service do
  subject { described_class.new }

  let(:domain) { 'obsolete.org' }
  let!(:old_account) { Fabricate(:account, domain: domain) }
  let!(:old_status_plain) { Fabricate(:status, account: old_account) }
  let!(:old_status_with_attachment) { Fabricate(:status, account: old_account) }
  let!(:old_attachment) { Fabricate(:media_attachment, account: old_account, status: old_status_with_attachment, file: attachment_fixture('attachment.jpg')) }

  describe 'for a suspension' do
    it 'refreshes instance view and removes associated records' do
      expect { subject.call(domain) }
        .to change { domain_instance_exists }.from(true).to(false)

      expect { old_account.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_status_plain.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_status_with_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { old_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
    end

    def domain_instance_exists
      Instance.exists?(domain: domain)
    end
  end
end
