# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftwareUpdate do
  describe 'Scopes' do
    describe '.urgent' do
      let!(:urgent_update) { Fabricate :software_update, urgent: true }
      let!(:non_urgent_update) { Fabricate :software_update, urgent: false }

      it 'returns records that are urgent' do
        expect(described_class.urgent)
          .to include(urgent_update)
          .and not_include(non_urgent_update)
      end
    end
  end

  describe '.by_version' do
    let!(:latest_update) { Fabricate :software_update, version: '4.0.0' }
    let!(:older_update) { Fabricate :software_update, version: '3.0.0' }

    it 'returns record in gem version order' do
      expect(described_class.by_version)
        .to eq([older_update, latest_update])
    end
  end

  describe '#pending?' do
    subject { described_class.new(version: update_version) }

    before { allow(Mastodon::Version).to receive(:gem_version).and_return(Gem::Version.new(mastodon_version)) }

    context 'when the runtime version is older than the update' do
      let(:mastodon_version) { '4.0.0' }
      let(:update_version) { '5.0.0' }

      it { is_expected.to be_pending }
    end

    context 'when the runtime version is newer than the update' do
      let(:mastodon_version) { '6.0.0' }
      let(:update_version) { '5.0.0' }

      it { is_expected.to_not be_pending }
    end

    context 'when the runtime version is same as the update' do
      let(:mastodon_version) { '4.0.0' }
      let(:update_version) { '4.0.0' }

      it { is_expected.to_not be_pending }
    end
  end

  describe '#outdated?' do
    subject { described_class.new(version: update_version) }

    before { allow(Mastodon::Version).to receive(:gem_version).and_return(Gem::Version.new(mastodon_version)) }

    context 'when the runtime version is older than the update' do
      let(:mastodon_version) { '4.0.0' }
      let(:update_version) { '5.0.0' }

      it { is_expected.to_not be_outdated }
    end

    context 'when the runtime version is newer than the update' do
      let(:mastodon_version) { '6.0.0' }
      let(:update_version) { '5.0.0' }

      it { is_expected.to be_outdated }
    end

    context 'when the runtime version is same as the update' do
      let(:mastodon_version) { '4.0.0' }
      let(:update_version) { '4.0.0' }

      it { is_expected.to be_outdated }
    end
  end

  describe '.pending_to_a' do
    before do
      allow(Mastodon::Version).to receive(:gem_version).and_return(Gem::Version.new(mastodon_version))

      Fabricate(:software_update, version: '3.4.42', type: 'patch', urgent: true)
      Fabricate(:software_update, version: '3.5.0', type: 'minor', urgent: false)
      Fabricate(:software_update, version: '4.2.0', type: 'major', urgent: false)
    end

    context 'when the Mastodon version is an outdated release' do
      let(:mastodon_version) { '3.4.0' }

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('3.4.42', '3.5.0', '4.2.0')
      end
    end

    context 'when the Mastodon version is more recent than anything last returned by the server' do
      let(:mastodon_version) { '5.0.0' }

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to eq []
      end
    end

    context 'when the Mastodon version is an outdated nightly' do
      let(:mastodon_version) { '4.3.0-nightly.2023-09-10' }

      before do
        Fabricate(:software_update, version: '4.3.0-nightly.2023-09-12', type: 'major', urgent: true)
      end

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('4.3.0-nightly.2023-09-12')
      end
    end

    context 'when the Mastodon version is a very outdated nightly' do
      let(:mastodon_version) { '4.2.0-nightly.2023-07-10' }

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('4.2.0')
      end
    end

    context 'when the Mastodon version is an outdated dev version' do
      let(:mastodon_version) { '4.3.0-0.dev.0' }

      before do
        Fabricate(:software_update, version: '4.3.0-0.dev.2', type: 'major', urgent: true)
      end

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('4.3.0-0.dev.2')
      end
    end

    context 'when the Mastodon version is an outdated beta version' do
      let(:mastodon_version) { '4.3.0-beta1' }

      before do
        Fabricate(:software_update, version: '4.3.0-beta2', type: 'major', urgent: true)
      end

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('4.3.0-beta2')
      end
    end

    context 'when the Mastodon version is an outdated beta version and there is a rc' do
      let(:mastodon_version) { '4.3.0-beta1' }

      before do
        Fabricate(:software_update, version: '4.3.0-rc1', type: 'major', urgent: true)
      end

      it 'returns the expected versions' do
        expect(described_class.pending_to_a.pluck(:version)).to contain_exactly('4.3.0-rc1')
      end
    end
  end
end
