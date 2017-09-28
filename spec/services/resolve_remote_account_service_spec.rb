require 'rails_helper'

RSpec.describe ResolveRemoteAccountService do
  subject { described_class.new }

  before do
    stub_request(:get, "https://quitter.no/.well-known/host-meta").to_return(request_fixture('.host-meta.txt'))
    stub_request(:get, "https://example.com/.well-known/webfinger?resource=acct:catsrgr8@example.com").to_return(status: 404)
    stub_request(:get, "https://redirected.com/.well-known/host-meta").to_return(request_fixture('redirected.host-meta.txt'))
    stub_request(:get, "https://example.com/.well-known/host-meta").to_return(status: 404)
    stub_request(:get, "https://quitter.no/.well-known/webfinger?resource=acct:gargron@quitter.no").to_return(request_fixture('webfinger.txt'))
    stub_request(:get, "https://redirected.com/.well-known/webfinger?resource=acct:gargron@redirected.com").to_return(request_fixture('webfinger.txt'))
    stub_request(:get, "https://redirected.com/.well-known/webfinger?resource=acct:hacker1@redirected.com").to_return(request_fixture('webfinger-hacker1.txt'))
    stub_request(:get, "https://redirected.com/.well-known/webfinger?resource=acct:hacker2@redirected.com").to_return(request_fixture('webfinger-hacker2.txt'))
    stub_request(:get, "https://quitter.no/.well-known/webfinger?resource=acct:catsrgr8@quitter.no").to_return(status: 404)
    stub_request(:get, "https://quitter.no/api/statuses/user_timeline/7477.atom").to_return(request_fixture('feed.txt'))
    stub_request(:get, "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))
    stub_request(:get, "https://localdomain.com/.well-known/host-meta").to_return(request_fixture('localdomain-hostmeta.txt'))
    stub_request(:get, "https://localdomain.com/.well-known/webfinger?resource=acct:foo@localdomain.com").to_return(status: 404)
    stub_request(:get, "https://webdomain.com/.well-known/webfinger?resource=acct:foo@localdomain.com").to_return(request_fixture('localdomain-webfinger.txt'))
    stub_request(:get, "https://webdomain.com/users/foo.atom").to_return(request_fixture('localdomain-feed.txt'))
  end

  it 'raises error if no such user can be resolved via webfinger' do
    expect(subject.call('catsrgr8@quitter.no')).to be_nil
  end

  it 'raises error if the domain does not have webfinger' do
    expect(subject.call('catsrgr8@example.com')).to be_nil
  end

  it 'prevents hijacking existing accounts' do
    account = subject.call('hacker1@redirected.com')
    expect(account.salmon_url).to_not eq 'https://hacker.com/main/salmon/user/7477'
  end

  it 'prevents hijacking inexisting accounts' do
    expect(subject.call('hacker2@redirected.com')).to be_nil
  end

  context 'with an OStatus account' do
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

    it 'follows a legitimate account redirection' do
      account = subject.call('gargron@redirected.com')

      expect(account.username).to eq 'gargron'
      expect(account.domain).to eq 'quitter.no'
      expect(account.remote_url).to eq 'https://quitter.no/api/statuses/user_timeline/7477.atom'
    end

    it 'returns a new remote account' do
      account = subject.call('foo@localdomain.com')

      expect(account.username).to eq 'foo'
      expect(account.domain).to eq 'localdomain.com'
      expect(account.remote_url).to eq 'https://webdomain.com/users/foo.atom'
    end
  end

  context 'with an ActivityPub account' do
    before do
      stub_request(:get, "https://ap.example.com/.well-known/webfinger?resource=acct:foo@ap.example.com").to_return(request_fixture('activitypub-webfinger.txt'))
      stub_request(:get, "https://ap.example.com/users/foo").to_return(request_fixture('activitypub-actor.txt'))
      stub_request(:get, "https://ap.example.com/users/foo.atom").to_return(request_fixture('activitypub-feed.txt'))
      stub_request(:get, %r{https://ap.example.com/users/foo/\w+}).to_return(status: 404)
    end

    it 'fallback to OStatus if actor json could not be fetched' do
      stub_request(:get, "https://ap.example.com/users/foo").to_return(status: 404)

      account = subject.call('foo@ap.example.com')

      expect(account.ostatus?).to eq true
      expect(account.remote_url).to eq 'https://ap.example.com/users/foo.atom'
    end

    it 'fallback to OStatus if actor json did not have inbox_url' do
      stub_request(:get, "https://ap.example.com/users/foo").to_return(request_fixture('activitypub-actor-noinbox.txt'))

      account = subject.call('foo@ap.example.com')

      expect(account.ostatus?).to eq true
      expect(account.remote_url).to eq 'https://ap.example.com/users/foo.atom'
    end

    it 'returns new remote account' do
      account = subject.call('foo@ap.example.com')

      expect(account.activitypub?).to eq true
      expect(account.domain).to eq 'ap.example.com'
      expect(account.inbox_url).to eq 'https://ap.example.com/users/foo/inbox'
    end

    pending
  end

  it 'processes one remote account at a time using locks' do
    wait_for_start = true
    fail_occurred  = false
    return_values  = []

    threads = Array.new(5) do
      Thread.new do
        true while wait_for_start
        begin
          return_values << described_class.new.call('foo@localdomain.com')
        rescue ActiveRecord::RecordNotUnique
          fail_occurred = true
        end
      end
    end

    wait_for_start = false
    threads.each(&:join)

    expect(fail_occurred).to be false
    expect(return_values).to_not include(nil)
  end
end
