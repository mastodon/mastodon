require 'rails_helper'

RSpec.describe ResolveAccountService, type: :service do
  subject { described_class.new }

  before do
    stub_request(:get, "https://quitter.no/.well-known/host-meta").to_return(request_fixture('.host-meta.txt'))
    stub_request(:get, "https://example.com/.well-known/webfinger?resource=acct:catsrgr8@example.com").to_return(status: 404)
    stub_request(:get, "https://example.com/.well-known/host-meta").to_return(status: 404)
    stub_request(:get, "https://quitter.no/avatar/7477-300-20160211190340.png").to_return(request_fixture('avatar.txt'))
    stub_request(:get, "https://quitter.no/.well-known/webfinger?resource=acct:catsrgr8@quitter.no").to_return(status: 404)
    stub_request(:get, "https://ap.example.com/.well-known/webfinger?resource=acct:foo@ap.example.com").to_return(request_fixture('activitypub-webfinger.txt'))
    stub_request(:get, "https://ap.example.com/users/foo").to_return(request_fixture('activitypub-actor.txt'))
    stub_request(:get, "https://ap.example.com/users/foo.atom").to_return(request_fixture('activitypub-feed.txt'))
    stub_request(:get, %r{https://ap.example.com/users/foo/\w+}).to_return(status: 404)
  end

  it 'raises error if no such user can be resolved via webfinger' do
    expect(subject.call('catsrgr8@quitter.no')).to be_nil
  end

  it 'raises error if the domain does not have webfinger' do
    expect(subject.call('catsrgr8@example.com')).to be_nil
  end

  context 'with an ActivityPub account' do
    it 'returns new remote account' do
      account = subject.call('foo@ap.example.com')

      expect(account.activitypub?).to eq true
      expect(account.domain).to eq 'ap.example.com'
      expect(account.inbox_url).to eq 'https://ap.example.com/users/foo/inbox'
    end

    context 'with multiple types' do
      before do
        stub_request(:get, "https://ap.example.com/users/foo").to_return(request_fixture('activitypub-actor-individual.txt'))
      end

      it 'returns new remote account' do
        account = subject.call('foo@ap.example.com')

        expect(account.activitypub?).to eq true
        expect(account.domain).to eq 'ap.example.com'
        expect(account.inbox_url).to eq 'https://ap.example.com/users/foo/inbox'
        expect(account.actor_type).to eq 'Person'
      end
    end
  end

  it 'processes one remote account at a time using locks' do
    wait_for_start = true
    fail_occurred  = false
    return_values  = Concurrent::Array.new

    # Preload classes that throw circular dependency errors in threads
    Account
    TagManager
    DomainBlock

    threads = Array.new(5) do
      Thread.new do
        true while wait_for_start

        begin
          return_values << described_class.new.call('foo@ap.example.com')
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
