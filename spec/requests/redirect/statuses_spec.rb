# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Redirect page for statuses' do
  describe 'GET /redirect/statuses/:id' do
    context 'with a remote status' do
      let(:status) { Fabricate :status, account: Fabricate(:account, domain: 'host.example') }

      it 'renders a page with link to resource' do
        get redirect_status_path(id: status.id)

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to have_link(ActivityPub::TagManager.instance.url_for(status))
      end
    end

    context 'with a local status' do
      let(:status) { Fabricate :status, account: Fabricate(:account, domain: nil) }

      it 'renders not found' do
        get redirect_status_path(id: status.id)

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'with a not distributable status' do
      let(:status) { Fabricate :status, visibility: :private }

      it 'renders not found' do
        get redirect_status_path(id: status.id)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
