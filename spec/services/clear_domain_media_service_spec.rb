require 'rails_helper'

RSpec.describe ClearDomainMediaService, type: :service do
  subject { ClearDomainMediaService.new }

  let!(:bad_account) { Fabricate(:account, username: 'badguy666', domain: 'evil.org') }
  let!(:bad_status1) { Fabricate(:status, account: bad_account, text: 'You suck') }
  let!(:bad_status2) { Fabricate(:status, account: bad_account, text: 'Hahaha') }
  let!(:bad_attachment) { Fabricate(:media_attachment, account: bad_account, status: bad_status2, file: attachment_fixture('attachment.jpg')) }

  describe 'for a silence with reject media' do
    before do
      subject.call(DomainBlock.create!(domain: 'evil.org', severity: :silence, reject_media: true))
    end

    it 'leaves the domains status and attachments, but clears media' do
      expect { bad_status1.reload }.to_not raise_error
      expect { bad_status2.reload }.to_not raise_error
      expect { bad_attachment.reload }.to_not raise_error
      expect(bad_attachment.file.exists?).to be false
    end
  end
end
