require 'rails_helper'

RSpec.describe ProcessMentionsService do
  let(:account)     { Fabricate(:account, username: 'alice') }
  let(:tag)         { Fabricate(:tag) }
  let(:status)      { Fabricate(:status, account: account, text: text) }

  subject { ProcessHashtagsService.new }

  before do
    subject.(status)
  end

  context 'when the status contains a hashtag' do
    let(:text) { "Hello, world! ##{tag.name}" }

    it 'associates the hashtag with the status' do
      expect(status.reload.tags).to contain_exactly(tag)
    end
  end

  context 'when the status contains a code block' do
    context 'and the code blcok contains a mention' do
      let(:text) { "Hello, world! `##{tag.name}`" }

      it 'does not associate the hashtag with the status' do
        expect(status.reload.tags).to be_empty
      end
    end
  end
end
