# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FanOutOnWriteService, type: :service do
  let(:author)   { Fabricate(:account, username: 'frederica') }
  let(:alice)    { Fabricate(:user, account: Fabricate(:account, username: 'tachibana')).account }
  let(:follower) { Fabricate(:account, username: 'syuko') }

  subject { FanOutOnWriteService.new }

  before do
    alice
    follower.follow!(author)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)
  end

  context 'visibility is public' do
    let(:status) { Fabricate(:status, text: 'Hello @tachibana', account: author) }

    context 'status is tagged' do
      let(:status) { Fabricate(:status, text: 'Hello @tachibana #hoge #fuga #nyowa', account: author, visibility: visibility) }
      let(:visibility) { :public }

      it do
        expect(Redis.current).to receive(:publish).with('timeline:public', anything)
        expect(Redis.current).to receive(:publish).with('timeline:public:local', anything)
        status.tags.pluck(:name).each do |tag_name|
          expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}", anything)
          expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:local", anything)
          expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized", anything)
          expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized:local", anything)
        end
        subject.call(status)
      end

      context 'visibility is unlisted' do
        let(:visibility) { :unlisted }

        it do
          status.tags.pluck(:name).each do |tag_name|
            expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized", anything)
            expect(Redis.current).to receive(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized:local", anything)
          end
          subject.call(status)
        end
      end
    end
  end
end
