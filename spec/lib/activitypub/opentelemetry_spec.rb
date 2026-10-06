# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/SpecFilePathFormat
# We write OpenTelemetry but files are like opentelemetry to
# follow the main gem naming convention
RSpec.describe ActivityPub::OpenTelemetry do
  subject { described_class }

  let(:payload) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'foo',
      'type' => 'Create',
    }
  end

  let(:span) { instance_double(OpenTelemetry::Trace::Span) }

  before do
    allow(span).to receive(:recording?).and_return(true)
    allow(span).to receive(:set_attribute)
  end

  describe '#decorate_span' do
    it 'adds attributes to span' do
      subject.decorate_span(span:, payload:)

      expect(span).to have_received(:set_attribute).with('activitypub.activity.id', payload['id'])
      expect(span).to have_received(:set_attribute).with('activitypub.activity.type', payload['type'])
    end

    it 'can use different namespaces' do
      subject.decorate_span(span:, payload:, namespace: 'object')

      expect(span).to have_received(:set_attribute).with('activitypub.object.id', payload['id'])
      expect(span).to have_received(:set_attribute).with('activitypub.object.type', payload['type'])
    end
  end

  describe '#decorate_current_span' do
    before do
      allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
    end

    it 'adds attributes to span' do
      subject.decorate_current_span(payload:)

      expect(span).to have_received(:set_attribute).with('activitypub.activity.id', payload['id'])
      expect(span).to have_received(:set_attribute).with('activitypub.activity.type', payload['type'])
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
