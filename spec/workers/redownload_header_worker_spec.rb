# frozen_string_literal: true

require 'rails_helper'

describe RedownloadHeaderWorker do
  subject { described_class.new }

  let(:header_remote_url) { 'https://remote.test/valid_avatar' }

  before do
    stub_request(:get, 'https://remote.test/valid_avatar').to_return(request_fixture('avatar.txt'))
  end

  describe 'perform' do
    context 'when the actor is an Account' do
      let!(:actor) { Fabricate(:account, header_remote_url: header_remote_url) }

      before do
        actor.header.destroy
        actor.header = nil
        actor.save!
      end

      it 'downloads and save the file' do
        expect { subject.perform(actor.id) }.to change { actor.reload.header_file_name.nil? }.from(true).to(false)
      end
    end

    context 'when the actor is a Group' do
      let!(:actor) { Fabricate(:group, header_remote_url: header_remote_url) }

      before do
        actor.header.destroy
        actor.header = nil
        actor.save!
      end

      it 'downloads and save the file' do
        expect { subject.perform(actor.id, 'Group') }.to change { actor.reload.header_file_name.nil? }.from(true).to(false)
      end
    end
  end
end
