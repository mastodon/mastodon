# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Imports' do
  let(:user) { Fabricate(:user) }
  let(:account) { user.account }

  before { sign_in user }

  describe 'POST /settings/imports' do
    it 'gracefully handles invalid nested params' do
      post settings_imports_path(form_import: 'invalid')

      expect(response)
        .to have_http_status(400)
    end

    describe 'with JSON' do
      subject { post settings_imports_path, params: { form_import: { type: 'custom_filters', mode: 'merge', data: data } } }

      let!(:data) { fixture_file_upload('custom_filters.json', 'application/json') }
      let(:confirm) { post confirm_settings_import_path(id: user.account.bulk_imports.last.id) }

      it 'redirects to confirm_settings_import_path' do
        subject
        expect(response).to have_http_status(302)
          .and redirect_to(settings_import_path(id: user.account.bulk_imports.last.id))
        expect(user.account.bulk_imports.last.state).to eq('unconfirmed')
        confirm
        expect(response).to have_http_status(302)
        expect(user.account.bulk_imports.last.state).to eq('scheduled')
      end
    end

    shared_examples 'unsuccessful import' do |type, file, content_type = 'text/plain'|
      subject do
        post settings_imports_path, params: {
          form_import: {
            type: type,
            mode: import_mode,
            data: fixture_file_upload(file, content_type),
          },
        }
      end

      it 'does not create an unconfirmed bulk import', :aggregate_failures do
        expect { subject }.to_not(change { user.account.bulk_imports.count })

        expect(response.body)
          .to include('field_with_errors')
      end
    end

    %w(merge overwrite).each do |mode|
      context "with #{mode} mode" do
        let(:import_mode) { mode }

        it_behaves_like 'unsuccessful import', 'following', 'domain_blocks.csv'
        it_behaves_like 'unsuccessful import', 'blocking', 'domain_blocks.csv'
        it_behaves_like 'unsuccessful import', 'muting', 'domain_blocks.csv'
        it_behaves_like 'unsuccessful import', 'following', 'empty.csv'
      end
    end

    context 'with custom filters' do
      let(:import_mode) { 'merge' }

      it_behaves_like 'unsuccessful import', 'custom_filters', 'empty.json', 'application/json'
    end
  end

  describe 'GET /settings/imports/:id' do
    before { get settings_import_path(bulk_import) }

    context 'with someone else\'s import' do
      let(:bulk_import) { Fabricate(:bulk_import, state: :unconfirmed) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with an already-confirmed import' do
      let(:bulk_import) { Fabricate(:bulk_import, account: user.account, state: :in_progress) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /settings/imports/:id/confirm' do
    subject { post confirm_settings_import_path(bulk_import) }

    context 'with someone else\'s import' do
      let(:bulk_import) { Fabricate(:bulk_import, state: :unconfirmed) }

      it 'does not change the import\'s state and returns missing', :aggregate_failures do
        expect { subject }.to_not(change { bulk_import.reload.state })

        expect(BulkImportWorker.jobs).to be_empty
        expect(response).to have_http_status(404)
      end
    end

    context 'with an already-confirmed import' do
      let(:bulk_import) { Fabricate(:bulk_import, account: user.account, state: :in_progress) }

      it 'does not change the import\'s state and returns missing', :aggregate_failures do
        expect { subject }.to_not(change { bulk_import.reload.state })

        expect(BulkImportWorker.jobs).to be_empty
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /settings/imports/:id' do
    subject { delete settings_import_path(bulk_import) }

    context 'with someone else\'s import' do
      let(:bulk_import) { Fabricate(:bulk_import, state: :unconfirmed) }

      it 'does not delete the import and returns missing', :aggregate_failures do
        expect { subject }.to_not(change { BulkImport.exists?(bulk_import.id) })

        expect(response).to have_http_status(404)
      end
    end

    context 'with an already-confirmed import' do
      let(:bulk_import) { Fabricate(:bulk_import, account: user.account, state: :in_progress) }

      it 'does not delete the import and returns missing', :aggregate_failures do
        expect { subject }.to_not(change { BulkImport.exists?(bulk_import.id) })

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET /settings/imports/:id/failures' do
    subject { get failures_settings_import_path(bulk_import, format: :csv) }

    shared_examples 'export failed rows' do |filename, expected_contents|
      let(:bulk_import) { Fabricate(:bulk_import, account: user.account, type: import_type, state: :finished) }

      before do
        rows.each { |data| Fabricate(:bulk_import_row, bulk_import: bulk_import, data: data) }
        bulk_import.update(total_items: bulk_import.rows.count, processed_items: bulk_import.rows.count, imported_items: 0)
      end

      it 'returns expected contents', :aggregate_failures do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response)
          .to have_attachment(filename)
        expect(response.body)
          .to eq expected_contents
      end
    end

    context 'with follows' do
      let(:import_type) { 'following' }

      let(:rows) do
        [
          { 'acct' => 'foo@bar' },
          { 'acct' => 'user@bar', 'show_reblogs' => false, 'notify' => true, 'languages' => %w(fr de) },
        ]
      end

      it_behaves_like 'export failed rows', 'following_accounts_failures.csv', "Account address,Show boosts,Notify on new posts,Languages\nfoo@bar,true,false,\nuser@bar,false,true,\"fr, de\"\n"
    end

    context 'with custom filters' do
      subject { get failures_settings_import_path(bulk_import, format: :json) }

      let(:import_type) { 'custom_filters' }
      let(:rows) do
        [
          {
            'title' => 'random title',
            'expires_at' => nil,
            'context' => ['public', 'account'],
            'action' => 'warn',
            'keywords_attributes' => [{
              'keyword' => 'all them keywords',
              'whole_word' => true,
            }, {
              'keyword' => 'more keywords even',
              'whole_word' => true,
            }],
            'statuses' => ['status'],
          },
        ]
      end
      let(:bulk_import) { Fabricate(:bulk_import, account: user.account, type: import_type, state: :finished) }

      before do
        rows.each { |data| Fabricate(:bulk_import_row, bulk_import: bulk_import, data: data) }
        bulk_import.update(total_items: bulk_import.rows.count, processed_items: bulk_import.rows.count, imported_items: 0)
      end

      it_behaves_like 'export failed rows', 'custom_filters_failures.json',
                      '{"custom_filters":[{"title":"random title","action":"warn","context":["public","account"],"statuses":["status"],"expires_at":null,"keywords_attributes":[{"keyword":"all them keywords","whole_word":true},{"keyword":"more keywords even","whole_word":true}]},{"title":"random title","action":"warn","context":["public","account"],"statuses":["status"],"expires_at":null,"keywords_attributes":[{"keyword":"all them keywords","whole_word":true},{"keyword":"more keywords even","whole_word":true}]}]}' # rubocop:disable Layout/LineLength
    end

    context 'with blocks' do
      let(:import_type) { 'blocking' }

      let(:rows) do
        [
          { 'acct' => 'foo@bar' },
          { 'acct' => 'user@bar' },
        ]
      end

      it_behaves_like 'export failed rows', 'blocked_accounts_failures.csv', "foo@bar\nuser@bar\n"
    end

    context 'with mutes' do
      let(:import_type) { 'muting' }

      let(:rows) do
        [
          { 'acct' => 'foo@bar' },
          { 'acct' => 'user@bar', 'hide_notifications' => false },
        ]
      end

      it_behaves_like 'export failed rows', 'muted_accounts_failures.csv', "Account address,Hide notifications\nfoo@bar,true\nuser@bar,false\n"
    end

    context 'with domain blocks' do
      let(:import_type) { 'domain_blocking' }

      let(:rows) do
        [
          { 'domain' => 'bad.domain' },
          { 'domain' => 'evil.domain' },
        ]
      end

      it_behaves_like 'export failed rows', 'blocked_domains_failures.csv', "bad.domain\nevil.domain\n"
    end

    context 'with bookmarks' do
      let(:import_type) { 'bookmarks' }

      let(:rows) do
        [
          { 'uri' => 'https://foo.com/1' },
          { 'uri' => 'https://foo.com/2' },
        ]
      end

      it_behaves_like 'export failed rows', 'bookmarks_failures.csv', "https://foo.com/1\nhttps://foo.com/2\n"
    end

    context 'with lists' do
      let(:import_type) { 'lists' }

      let(:rows) do
        [
          { 'list_name' => 'Amigos', 'acct' => 'user@example.com' },
          { 'list_name' => 'Frenemies', 'acct' => 'user@org.org' },
        ]
      end

      it_behaves_like 'export failed rows', 'lists_failures.csv', "Amigos,user@example.com\nFrenemies,user@org.org\n"
    end
  end
end
