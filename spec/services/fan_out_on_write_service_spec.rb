require 'rails_helper'

RSpec.describe FanOutOnWriteService, type: :service do
  let(:last_active_at) { Time.now.utc }

  let!(:alice) { Fabricate(:user, current_sign_in_at: last_active_at).account }
  let!(:bob)   { Fabricate(:user, current_sign_in_at: last_active_at, account_attributes: { username: 'bob' }).account }
  let!(:tom)   { Fabricate(:user, current_sign_in_at: last_active_at).account }

  subject { described_class.new }

  let(:status) { Fabricate(:status, account: alice, visibility: visibility, text: 'Hello @bob #hoge') }

  before do
    bob.follow!(alice)
    tom.follow!(alice)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)

    allow(redis).to receive(:publish)

    subject.call(status)
  end

  def home_feed_of(account)
    HomeFeed.new(account).get(10).map(&:id)
  end

  context 'when status is public' do
    let(:visibility) { 'public' }

    it 'is added to the home feed of its author' do
      expect(home_feed_of(alice)).to include status.id
    end

    it 'is added to the home feed of a follower' do
      expect(home_feed_of(bob)).to include status.id
      expect(home_feed_of(tom)).to include status.id
    end

    it 'is broadcast to the hashtag stream' do
      expect(redis).to have_received(:publish).with('timeline:hashtag:hoge', anything)
      expect(redis).to have_received(:publish).with('timeline:hashtag:hoge:local', anything)
    end

    it 'is broadcast to the public stream' do
      expect(redis).to have_received(:publish).with('timeline:public', anything)
      expect(redis).to have_received(:publish).with('timeline:public:local', anything)
    end
  end

  context 'when status is limited' do
    let(:visibility) { 'limited' }

    it 'is added to the home feed of its author' do
      expect(home_feed_of(alice)).to include status.id
    end

    it 'is added to the home feed of the mentioned follower' do
      expect(home_feed_of(bob)).to include status.id
    end

    it 'is not added to the home feed of the other follower' do
      expect(home_feed_of(tom)).to_not include status.id
    end

    it 'is not broadcast publicly' do
      expect(redis).to_not have_received(:publish).with('timeline:hashtag:hoge', anything)
      expect(redis).to_not have_received(:publish).with('timeline:public', anything)
    end
  end

  context 'when status is private' do
    let(:visibility) { 'private' }

    it 'is added to the home feed of its author' do
      expect(home_feed_of(alice)).to include status.id
    end

    it 'is added to the home feed of a follower' do
      expect(home_feed_of(bob)).to include status.id
      expect(home_feed_of(tom)).to include status.id
    end

    it 'is not broadcast publicly' do
      expect(redis).to_not have_received(:publish).with('timeline:hashtag:hoge', anything)
      expect(redis).to_not have_received(:publish).with('timeline:public', anything)
    end
  end

  context 'when status is direct' do
    let(:visibility) { 'direct' }

    it 'is added to the home feed of its author' do
      expect(home_feed_of(alice)).to include status.id
    end

    it 'is added to the home feed of the mentioned follower' do
      expect(home_feed_of(bob)).to include status.id
    end

    it 'is not added to the home feed of the other follower' do
      expect(home_feed_of(tom)).to_not include status.id
    end

    it 'is not broadcast publicly' do
      expect(redis).to_not have_received(:publish).with('timeline:hashtag:hoge', anything)
      expect(redis).to_not have_received(:publish).with('timeline:public', anything)
    end
  end
end
