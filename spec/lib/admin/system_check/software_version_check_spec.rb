# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::SoftwareVersionCheck do
  include RoutingHelper

  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  describe 'skip?' do
    context 'when user cannot view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(false) }

      it 'returns true' do
        expect(check.skip?).to be true
      end
    end

    context 'when user can view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(true) }

      it 'returns false' do
        expect(check.skip?).to be false
      end

      context 'when checks are disabled' do
        around do |example|
          original = Rails.configuration.x.mastodon.software_update_url
          Rails.configuration.x.mastodon.software_update_url = ''
          example.run
          Rails.configuration.x.mastodon.software_update_url = original
        end

        it 'returns true' do
          expect(check.skip?).to be true
        end
      end
    end
  end

  describe 'pass?' do
    context 'when there is no known update' do
      it 'returns true' do
        expect(check.pass?).to be true
      end
    end

    context 'when there is a non-urgent major release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'major', urgent: false)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when there is an urgent major release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'major', urgent: true)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when there is an urgent minor release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'minor', urgent: true)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when there is an urgent patch release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: true)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when there is a non-urgent patch release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: false)
      end

      it 'returns false' do
        expect(check.pass?).to be false
      end
    end
  end

  describe 'message' do
    context 'when there is a non-urgent patch release pending' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: false)
      end

      it 'sends class name symbol to message instance' do
        allow(Admin::SystemCheck::Message).to receive(:new)
          .with(:software_version_patch_check, anything, anything)

        check.message

        expect(Admin::SystemCheck::Message).to have_received(:new)
          .with(:software_version_patch_check, nil, admin_software_updates_path)
      end
    end

    context 'when there is an urgent patch release pending' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: true)
      end

      it 'sends class name symbol to message instance' do
        allow(Admin::SystemCheck::Message).to receive(:new)
          .with(:software_version_critical_check, anything, anything, anything)

        check.message

        expect(Admin::SystemCheck::Message).to have_received(:new)
          .with(:software_version_critical_check, nil, admin_software_updates_path, true)
      end
    end
  end
end
