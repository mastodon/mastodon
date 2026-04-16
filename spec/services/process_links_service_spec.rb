# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessLinksService do
  subject { described_class.new }

  let(:account) { Fabricate(:account, username: 'alice') }

  context 'when status mentions known collections' do
    let!(:collection) { Fabricate(:collection) }
    let(:status) { Fabricate(:status, account: account, text:, visibility: :public) }

    context 'when the collection is mentioned by URI' do
      let(:text) { "Hello check out this collection! #{ActivityPub::TagManager.instance.uri_for(collection)}" }

      it 'creates a tagged object' do
        expect { subject.call(status) }
          .to change { status.tagged_objects.count }.by(1)
      end
    end

    context 'when the collection is mentioned by URL' do
      let(:text) { "Hello check out this collection! #{ActivityPub::TagManager.instance.url_for(collection)}" }

      it 'creates a tagged object' do
        expect { subject.call(status) }
          .to change { status.tagged_objects.count }.by(1)
      end
    end
  end

  context 'when status has a generic link to something that is not a collection' do
    let(:status) { Fabricate(:status, account: account, text: 'Hello check out my personal web page: https://example.com/test', visibility: :public) }

    before do
      stub_request(:get, 'https://example.com/test').to_return(status: 404)
    end

    it 'skips the link and does not create a tagged object' do
      expect { expect { subject.call(status) }.to_not raise_error }
        .to not_change { status.tagged_objects.count }.from(0)
    end
  end
end
