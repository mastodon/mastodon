# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::MediaPrivacyCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check available to devops users'

  describe 'pass?' do
    context 'when the media cannot be listed' do
      before do
        stub_request(:get, /#{Regexp.quote(Rails.configuration.x.local_domain)}/).to_return(status: 200, body: 'a list of no files')
      end

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe 'message' do
    it 'sends values to message instance' do
      allow(Admin::SystemCheck::Message).to receive(:new).with(nil, nil, nil, critical: true)

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(nil, nil, nil, critical: true)
    end
  end
end
