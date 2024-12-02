# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeDomainService do
  subject { described_class.new }

  let(:domain) { 'obsolete.org' }
  let!(:account) { Fabricate(:account, domain: domain) }
  let!(:status_plain) { Fabricate(:status, account: account) }
  let!(:status_with_attachment) { Fabricate(:status, account: account) }
  let!(:attachment) { Fabricate(:media_attachment, account: account, status: status_with_attachment, file: attachment_fixture('attachment.jpg')) }

  describe 'for a suspension' do
    it 'refreshes instance view and removes associated records' do
      expect { subject.call(domain) }
        .to change { domain_instance_exists }.from(true).to(false)

      expect { account.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { status_plain.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { status_with_attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
      expect { attachment.reload }.to raise_exception ActiveRecord::RecordNotFound
    end

    def domain_instance_exists
      Instance.exists?(domain: domain)
    end
  end
end
