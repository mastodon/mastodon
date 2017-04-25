require 'rails_helper'

RSpec.describe FollowRemoteAccountService do
  subject { FollowRemoteAccountService.new }

  before do
    stub_request(:get, "https://quitter.no/.well-known/host-meta").to_return(request_fixture('.host-meta.txt'))
    stub_request(:get, "https://example.com/.well-known/host-meta").to_return(status: 404)
    stub_request(:get, "https://quitter.no/.well-known/webfinger?resource=acct:gargron@quitter.no").to_return(request_fixture('webfinger.txt'))
    stub_request(:get, "https://quitter.no/.well-known/webfinger?resource=acct:catsrgr8@quitter.no").to_return(status: 404)
    stub_request(:get, "https://quitter.no/api/statuses/user_timeline/7477.atom").to_return(request_fixture('feed.txt'))
    stub_request(:get, "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))
  end

  it 'raises error if no such user can be resolved via webfinger' do
    expect { subject.call('catsrgr8@quitter.no') }.to raise_error Goldfinger::Error
  end

  it 'raises error if the domain does not have webfinger' do
    expect { subject.call('catsrgr8@example.com') }.to raise_error Goldfinger::Error
  end

  it 'returns an already existing remote account' do
    old_account      = Fabricate(:account, username: 'gargron', domain: 'quitter.no')
    returned_account = subject.call('gargron@quitter.no')

    expect(old_account.id).to eq returned_account.id
  end

  it 'returns a new remote account' do
    account = subject.call('gargron@quitter.no')

    expect(account.username).to eq 'gargron'
    expect(account.domain).to eq 'quitter.no'
    expect(account.remote_url).to eq 'https://quitter.no/api/statuses/user_timeline/7477.atom'
  end
end
