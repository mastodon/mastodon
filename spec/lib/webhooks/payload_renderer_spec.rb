# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhooks::PayloadRenderer do
  subject(:renderer) { described_class.new(json) }

  let(:event)   { Webhooks::EventPresenter.new(type, object) }
  let(:payload) { ActiveModelSerializers::SerializableResource.new(event, serializer: REST::Admin::WebhookEventSerializer, scope: nil, scope_name: :current_user).as_json }
  let(:json)    { Oj.dump(payload) }

  describe '#render' do
    context 'when event is account.approved' do
      let(:type)   { 'account.approved' }
      let(:object) { Fabricate(:account, display_name: 'Foo"') }

      it 'renders event-related variables into template' do
        expect(renderer.render('foo={{event}}')).to eq 'foo=account.approved'
      end

      it 'renders event-specific variables into template' do
        expect(renderer.render('foo={{object.username}}')).to eq "foo=#{object.username}"
      end

      it 'escapes values for use in JSON' do
        expect(renderer.render('foo={{object.account.display_name}}')).to eq 'foo=Foo\\"'
      end
    end
  end
end
