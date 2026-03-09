# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessLinksService do
  subject { described_class.new }

  let(:account) { Fabricate(:account, username: 'alice') }

  context 'when status mentions known collections' do
    let!(:collection) { Fabricate(:collection) }
    let(:status) { Fabricate(:status, account: account, text: "Hello check out this collection! #{ActivityPub::TagManager.instance.uri_for(collection)}", visibility: :public) }

    it 'creates a tagged object' do
      expect { subject.call(status) }
        .to change { status.tagged_objects.count }.by(1)
    end
  end
end
