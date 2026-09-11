# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhooks::PayloadRenderer do
  subject(:renderer) { described_class.new(payload.to_json) }

  let(:event)   { Webhooks::EventPresenter.new(type, object) }
  let(:payload) { ActiveModelSerializers::SerializableResource.new(event, serializer: REST::Admin::WebhookEventSerializer, scope: nil, scope_name: :current_user).as_json }

  describe '#render' do
    subject { renderer.render(template) }

    context 'when event is account.approved' do
      let(:type)   { 'account.approved' }
      let(:object) { Fabricate(:account, display_name: 'Foo"', username: 'foofoobarbar') }

      context 'with event-related variables' do
        let(:template) { 'foo={{event}}' }

        it { is_expected.to eq('foo=account.approved') }
      end

      context 'with event-specific variables' do
        let(:template) { 'foo={{object.username}}' }

        it { is_expected.to eq('foo=foofoobarbar') }
      end

      context 'with values needing JSON escape' do
        let(:template) { 'foo={{object.account.display_name}}' }

        it { is_expected.to eq('foo=Foo\\"') }
      end
    end
  end
end
