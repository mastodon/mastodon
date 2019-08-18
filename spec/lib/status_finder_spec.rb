# frozen_string_literal: true

require 'rails_helper'

describe StatusFinder do
  include RoutingHelper

  describe '#status' do
    subject { described_class.new(url) }

    context 'with a status url' do
      let(:status) { Fabricate(:status) }
      let(:url) { short_account_status_url(account_username: status.account.username, id: status.id) }

      it 'finds the stream entry' do
        expect(subject.status).to eq(status)
      end

      it 'raises an error if action is not :show' do
        recognized = Rails.application.routes.recognize_path(url)
        expect(recognized).to receive(:[]).with(:action).and_return(:create)
        expect(Rails.application.routes).to receive(:recognize_path).with(url).and_return(recognized)

        expect { subject.status }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a remote url even if id exists on local' do
      let(:status) { Fabricate(:status) }
      let(:url) { "https://example.com/users/test/statuses/#{status.id}" }

      it 'raises an error' do
        expect { subject.status }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a plausible url' do
      let(:url) { 'https://example.com/users/test/updates/123/embed' }

      it 'raises an error' do
        expect { subject.status }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an unrecognized url' do
      let(:url) { 'https://example.com/about' }

      it 'raises an error' do
        expect { subject.status }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
