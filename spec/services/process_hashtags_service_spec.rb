# frozen_string_literal: true

require 'rails_helper'

describe ProcessHashtagsService do
  describe '.call' do
    context 'if status is local' do
      let(:account) { Fabricate(:account, domain: nil) }

      it 'deletes the recent use of the same tags' do
        tag = Fabricate(:tag, name: 'name')
        recently_used_tag = Fabricate(:recently_used_tag, account: account, tag: tag)
        status = Fabricate(:status, account: account, text: '#name')

        ProcessHashtagsService.new.call(status)

        expect{ recently_used_tag.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'records the use of tags with increased index if previously used tags are recorded' do
        Fabricate(:recently_used_tag, account: account, index: 1)
        status = Fabricate(:status, account: account, text: '#name')

        ProcessHashtagsService.new.call(status)

        expect(account.recently_used_tags.find_by!(tag: 'name').index).to eq 2
      end

      it 'records the use of tags even if previously used tags are not recorded' do
        status = Fabricate(:status, account: account, text: '#name')
        ProcessHashtagsService.new.call(status)
        expect(account.recently_used_tags.where(tag: 'name')).to exist
      end

      it 'deletes old use of tag' do
        old = Fabricate(:recently_used_tag, account: account, index: 1)
        Fabricate(:recently_used_tag, account: account, index: 1002)
        status = Fabricate(:status, account: account)

        ProcessHashtagsService.new.call(status)

        expect{ old.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
