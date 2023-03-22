# frozen_string_literal: true

require 'rails_helper'

describe Admin::SystemCheck::MediaPrivacyCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  describe 'skip?' do
    context 'when user can view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(true) }

      it 'returns false' do
        expect(check.skip?).to be false
      end
    end

    context 'when user cannot view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(false) }

      it 'returns true' do
        expect(check.skip?).to be true
      end
    end
  end

  describe 'pass?' do
    context 'when the media cannot be listed' do
      before do
        stub_request(:get, /ngrok.io/).to_return(status: 200, body: 'a list of no files')
      end

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe 'message' do
    it 'sends values to message instance' do
      allow(Admin::SystemCheck::Message).to receive(:new).with(nil, nil, nil, true)

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(nil, nil, nil, true)
    end
  end
end
