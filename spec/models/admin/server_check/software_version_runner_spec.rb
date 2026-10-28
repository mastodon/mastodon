# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::SoftwareVersionRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }

  it_behaves_like 'a check runner available to devops users'

  describe '#run' do
    subject(:result) { runner.run }

    context 'when software checks are disabled' do
      around do |example|
        original = Rails.configuration.x.mastodon.software_update_url
        Rails.configuration.x.mastodon.software_update_url = ''
        example.run
      ensure
        Rails.configuration.x.mastodon.software_update_url = original
      end

      it { is_expected.to be_ok }
    end

    context 'when there is no known update' do
      it { is_expected.to be_ok }
    end

    context 'when there is a non-urgent major release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'major', urgent: false)
      end

      it { is_expected.to be_pending }

      it 'sets the type to regular' do
        expect(result.data).to include(reason: :regular)
      end
    end

    context 'when there is a urgent minor release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'minor', urgent: true)
      end

      it { is_expected.to be_pending }

      it 'sets the type to urgent' do
        expect(result.data).to include(reason: :urgent)
      end
    end

    context 'when there is an urgent patch release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: true)
      end

      it { is_expected.to be_pending }

      it 'sets the type to urgent' do
        expect(result.data).to include(reason: :urgent)
      end
    end

    context 'when there is a non-urgent patch release' do
      before do
        Fabricate(:software_update, version: '99.99.99', type: 'patch', urgent: false)
      end

      it { is_expected.to be_pending }

      it 'sets the type to patch' do
        expect(result.data).to include(reason: :patch)
      end
    end
  end
end
