# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessHashtagsService do
  describe '#call' do
    let!(:prior_tag) { Fabricate :tag, name: 'priortag' }
    let!(:featured_tag) { Fabricate :featured_tag, account: status.account, tag: prior_tag }

    context 'when status is distributable' do
      let(:status) { Fabricate(:status, visibility: :public, text: 'With tags #one #two', tags: [prior_tag]) }

      it 'applies the tags from the status text and removes previous unused tags' do
        expect { subject.call(status) }
          .to change(Tag, :count).by(2)
          .and change { status.reload.tags.map(&:name) }.from(contain_exactly('priortag')).to(contain_exactly('one', 'two'))
          .and change { featured_tag.reload.statuses_count }.by(-1)
      end
    end

    context 'when status is not distributable' do
      let(:status) { Fabricate(:status, visibility: :private, text: 'With tags #one #two', tags: [prior_tag]) }

      it 'applies the tags but does not modify featured tags' do
        expect { subject.call(status) }
          .to change(Tag, :count).by(2)
          .and change { status.reload.tags.map(&:name) }.from(contain_exactly('priortag')).to(contain_exactly('one', 'two'))
          .and(not_change { featured_tag.reload.statuses_count })
      end
    end

    context 'when tags do not change' do
      let(:status) { Fabricate(:status, visibility: :public, text: 'With tags #priortag', tags: [prior_tag]) }

      it 'does not modify tags or featured tags' do
        expect { subject.call(status) }
          .to not_change(Tag, :count)
          .and not_change { status.reload.tags.map(&:name) }.from(contain_exactly('priortag'))
          .and(not_change { featured_tag.reload.statuses_count })
      end
    end
  end
end
