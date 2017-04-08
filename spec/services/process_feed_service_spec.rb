require 'rails_helper'

RSpec.describe ProcessFeedService do
  let(:body) { File.read(File.join(Rails.root, 'spec', 'fixtures', 'xml', 'mastodon.atom')) }
  let(:account) { Fabricate(:account, username: 'localhost', domain: 'kickass.zone') }

  subject { ProcessFeedService.new }

  before do
    stub_request(:post, "https://pubsubhubbub.superfeedr.com/").to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://kickass.zone/system/accounts/avatars/000/000/001/large/eris.png").to_return(request_fixture('avatar.txt'))
    stub_request(:get, "http://kickass.zone/system/media_attachments/files/000/000/002/original/morpheus_linux.jpg?1476059910").to_return(request_fixture('attachment1.txt'))
    stub_request(:get, "http://kickass.zone/system/media_attachments/files/000/000/003/original/gizmo.jpg?1476060065").to_return(request_fixture('attachment2.txt'))

    subject.call(body, account)
  end

  it 'updates remote user\'s account information' do
    account.reload
    expect(account.display_name).to eq '::1'
    expect(account).to have_attached_file(:avatar)
  end

  it 'creates posts' do
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=1:objectType=Status')).to_not be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=2:objectType=Status')).to_not be_nil
  end

  it 'ignores delete statuses unless they existed before' do
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=3:objectType=Status')).to be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=12:objectType=Status')).to be_nil
  end

  it 'does not create statuses for follows' do
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=1:objectType=Follow')).to be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=2:objectType=Follow')).to be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=4:objectType=Follow')).to be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=7:objectType=Follow')).to be_nil
  end

  it 'does not create statuses for favourites' do
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=2:objectType=Favourite')).to be_nil
    expect(Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=3:objectType=Favourite')).to be_nil
  end

  it 'creates posts with media' do
    status = Status.find_by(uri: 'tag:kickass.zone,2016-10-10:objectId=14:objectType=Status')

    expect(status).to_not be_nil
    expect(status.media_attachments.first).to have_attached_file(:file)
  end
end
