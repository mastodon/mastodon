# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusesController do
  render_views

  describe 'GET #show' do
    let(:account) { Fabricate(:account) }
    let(:status)  { Fabricate(:status, account: account) }

    context 'when signed-in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      context 'when status is public' do
        before do
          get :show, params: { account_username: status.account.username, id: status.id, format: format }
        end

        context 'with HTML' do
          let(:format) { 'html' }

          it 'renders status successfully', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and render_template(:show)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('private'),
              'Link' => include('activity+json')
            )
            expect(response.body).to include status.text
          end
        end

        context 'with JSON' do
          let(:format) { 'json' }

          it 'renders ActivityPub Note object successfully', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('private'),
              'Content-Type' => include('application/activity+json'),
              'Link' => include('activity+json')
            )
            expect(response.parsed_body)
              .to include(content: include(status.text))
          end
        end
      end

      context 'when status is private' do
        let(:status) { Fabricate(:status, account: account, visibility: :private) }

        context 'when user is authorized to see it' do
          before do
            user.account.follow!(account)
            get :show, params: { account_username: status.account.username, id: status.id, format: format }
          end

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              expect(response)
                .to have_http_status(200)
                .and render_template(:show)

              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body).to include status.text
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object successfully', :aggregate_failures do
              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )
              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          before do
            get :show, params: { account_username: status.account.username, id: status.id, format: format }
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'returns http not found' do
              expect(response).to have_http_status(404)
            end
          end

          context 'with HTML' do
            let(:format) { 'html' }

            it 'returns http not found' do
              expect(response).to have_http_status(404)
            end
          end
        end
      end

      context 'when status is direct' do
        let(:status) { Fabricate(:status, account: account, visibility: :direct) }

        context 'when user is authorized to see it' do
          before do
            Fabricate(:mention, account: user.account, status: status)
            get :show, params: { account_username: status.account.username, id: status.id, format: format }
          end

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              expect(response)
                .to have_http_status(200)
                .and render_template(:show)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body).to include status.text
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object successfully' do
              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )
              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          before do
            get :show, params: { account_username: status.account.username, id: status.id, format: format }
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'returns http not found' do
              expect(response).to have_http_status(404)
            end
          end

          context 'with HTML' do
            let(:format) { 'html' }

            it 'returns http not found' do
              expect(response).to have_http_status(404)
            end
          end
        end
      end
    end
  end
end
