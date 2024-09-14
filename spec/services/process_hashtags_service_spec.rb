# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessHashtagsService do
  describe '#call' do
    let(:status) { Fabricate(:status, visibility: :public, text: 'With tags #one #two') }

    it 'applies the tags from the status text' do
      expect { subject.call(status) }
        .to change(Tag, :count).by(2)
      expect(status.reload.tags.map(&:name))
        .to contain_exactly('one', 'two')
    end
  end
end
