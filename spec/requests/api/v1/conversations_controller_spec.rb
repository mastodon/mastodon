# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::ConversationsController do
  let!(:other) { Fabricate(:user).account }
  let!(:conversation_status) do
    PostStatusService.new.call(other, text: "Hello @#{user.account.acct}", visibility: 'direct')
  end
  let!(:account_conversation) { AccountConversation.where(account: user.account).last }

  path '/api/v1/conversations/{id}/read' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('read conversation') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsReadConversation'
      rswag_auth_scope %w(write write:conversations)
      description <<~MD
        **Mark a conversation as read**
        
        Direct conversations with other participants.  
        *Currently, just threads containing a post with "direct" visibility.*

      MD

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Conversation'
        let(:id) { account_conversation.id }
        include_context 'user token auth'

        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to include({
            id: account_conversation.id.to_s,
            accounts: [
              include({
                id: other.id.to_s,
              }),
            ],
            last_status: include({
              id: account_conversation.last_status_id.to_s,
              account: include({ id: other.id.to_s }),
              mentions: match_array(
                [
                  include({ id: user.account.id.to_s }),
                ]
              ),
            }),
            unread: false,
          })
        end
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { account_conversation.id }
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end

      response(404, 'Not found') do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        include_context 'user token auth'
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/conversations' do
    get('list conversations') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsListConversation'
      description <<~MD
        **List all conversations for current user**

        Direct conversations with other participants.  
        *Currently, just threads containing a post with "direct" visibility.*

      MD
      rswag_auth_scope %w(read read:statuses)
      rswag_page_params limit_desc: <<~MD
        Maximum number of results to return.  
        Defaults to 20 conversations.  
        Max 40 conversations.
      MD
      include_context 'user token auth'

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/Conversation' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 1).and(
            match_array(
              [
                include({
                  id: account_conversation.id.to_s,
                  accounts: [
                    include({
                      id: other.id.to_s,
                    }),
                  ],
                  last_status: include({
                    id: account_conversation.last_status_id.to_s,
                    account: include({ id: other.id.to_s }),
                    mentions: match_array(
                      [
                        include({ id: user.account.id.to_s }),
                      ]
                    ),
                  }),
                  unread: true,
                }),
              ]
            )
          )
        end
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        include_context 'user token auth' do
          let(:user_token_scopes) { 'read:bookmarks' }
        end
        rswag_add_examples!
        run_test!
      end
    end
  end

  path '/api/v1/conversations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete conversation') do
      tags 'Api', 'V1', 'Conversations'
      operationId 'v1ConversationsDeleteConversation'
      description <<~MD
        **Removes a conversation from your list of conversations**

        Direct conversations with other participants.  
        *Currently, just threads containing a post with "direct" visibility.*

      MD
      rswag_auth_scope %w(write write:conversations)

      response(200, 'successful') do
        schema type: :object, properties: {}
        let(:id) { account_conversation.id }
        include_context 'user token auth'

        rswag_add_examples!
        run_test! do
          expect(AccountConversation.exists?(id: account_conversation.id)).to be(false)
        end
      end

      response(401, 'Unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { account_conversation.id }
        include_context 'user token auth' do
          let(:authorization) { 'Bearer token666invalid' }
        end

        rswag_add_examples!
        run_test!
      end

      response(403, 'Outside token scope') do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { account_conversation.id }

        include_context 'user token auth' do
          let(:user_token_scopes) { 'read' }
        end
        rswag_add_examples!
        run_test!
      end

      response(404, 'Not found') do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        include_context 'user token auth'
        rswag_add_examples!
        run_test!
      end
    end
  end
end
