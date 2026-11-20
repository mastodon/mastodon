# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceFilter do
  subject { described_class.new(params) }

  describe '#results' do
    let!(:healthy_instance) { Fabricate(:instance, domain: 'healthy.com') }
    let!(:failing_instance) { Fabricate(:instance, domain: 'failing.com') }
    let!(:unavailable_instance) { Fabricate(:instance, domain: 'unavailable.com') }
    let!(:unavailable_domain) { Fabricate(:unavailable_domain, domain: 'unavailable.com') }

    before do
      allow(DeliveryFailureTracker).to receive(:warning_domains).and_return(['failing.com'])
    end

    let!(:limited_instance) { Fabricate(:instance, domain: 'limited.com') }
    let!(:limited_block) { Fabricate(:domain_block, domain: 'limited.com', severity: :silence) }
    let!(:suspended_instance) { Fabricate(:instance, domain: 'suspended.com') }
    let!(:suspended_block) { Fabricate(:domain_block, domain: 'suspended.com', severity: :suspend) }
    let!(:reject_media_instance) { Fabricate(:instance, domain: 'reject-media.com') }
    let!(:reject_media_block) { Fabricate(:domain_block, domain: 'reject-media.com', severity: :noop, reject_media: true) }

    context 'with limited = "1"' do
      let(:params) { { limited: '1' } }

      it 'returns all blocked instances (limited, suspended, and reject_media)' do
        expect(subject.results).to include(limited_instance)
        expect(subject.results).to include(suspended_instance)
        expect(subject.results).to include(reject_media_instance)
      end
    end

    context 'with limited = "limited"' do
      let(:params) { { limited: 'limited' } }

      it 'returns strictly limited (silenced) instances' do
        expect(subject.results).to include(limited_instance)
        expect(subject.results).to_not include(suspended_instance)
        expect(subject.results).to_not include(reject_media_instance)
      end
    end

    context 'with limited = "suspended"' do
      let(:params) { { limited: 'suspended' } }

      it 'returns strictly suspended instances' do
        expect(subject.results).to include(suspended_instance)
        expect(subject.results).to_not include(limited_instance)
        expect(subject.results).to_not include(reject_media_instance)
      end
    end

    context 'with limited = "reject_media"' do
      let(:params) { { limited: 'reject_media' } }

      it 'returns instances that reject media' do
        expect(subject.results).to include(reject_media_instance)
        expect(subject.results).to_not include(limited_instance)
        expect(subject.results).to_not include(suspended_instance)
      end
    end

    context 'with availability = "healthy"' do
      let(:params) { { availability: 'healthy' } }

      it 'returns instances that are neither failing nor unavailable' do
        expect(subject.results).to include(healthy_instance)
        expect(subject.results).to_not include(failing_instance)
        expect(subject.results).to_not include(unavailable_instance)
      end
    end

    context 'with availability = "failing"' do
      let(:params) { { availability: 'failing' } }

      it 'returns failing instances' do
        expect(subject.results).to include(failing_instance)
        expect(subject.results).to_not include(healthy_instance)
        expect(subject.results).to_not include(unavailable_instance)
      end
    end

    context 'with availability = "unavailable"' do
      let(:params) { { availability: 'unavailable' } }

      it 'returns unavailable instances' do
        expect(subject.results).to include(unavailable_instance)
        expect(subject.results).to_not include(healthy_instance)
        expect(subject.results).to_not include(failing_instance)
      end
    end
  end
end
