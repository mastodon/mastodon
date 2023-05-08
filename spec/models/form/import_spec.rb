# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::Import do
  subject { described_class.new(current_account: account, type: import_type, mode: import_mode, data: data) }

  let(:account)     { Fabricate(:account) }
  let(:data)        { fixture_file_upload(import_file) }
  let(:import_mode) { 'merge' }

  describe 'validations' do
    shared_examples 'incompatible import type' do |type, file|
      let(:import_file) { file }
      let(:import_type) { type }

      it 'has errors' do
        subject.validate
        expect(subject.errors[:data]).to include(I18n.t('imports.errors.incompatible_type'))
      end
    end

    shared_examples 'too many CSV rows' do |type, file, allowed_rows|
      let(:import_file) { file }
      let(:import_type) { type }

      before do
        stub_const 'Form::Import::ROWS_PROCESSING_LIMIT', allowed_rows
      end

      it 'has errors' do
        subject.validate
        expect(subject.errors[:data]).to include(I18n.t('imports.errors.over_rows_processing_limit', count: Form::Import::ROWS_PROCESSING_LIMIT))
      end
    end

    shared_examples 'valid import' do |type, file|
      let(:import_file) { file }
      let(:import_type) { type }

      it 'passes validation' do
        expect(subject).to be_valid
      end
    end

    context 'when the file too large' do
      let(:import_type) { 'following' }
      let(:import_file) { 'imports.txt' }

      before do
        stub_const 'Form::Import::FILE_SIZE_LIMIT', 5
      end

      it 'has errors' do
        subject.validate
        expect(subject.errors[:data]).to include(I18n.t('imports.errors.too_large'))
      end
    end

    context 'when the CSV file is malformed CSV' do
      let(:import_type) { 'following' }
      let(:import_file) { 'boop.ogg' }

      it 'has errors' do
        # NOTE: not testing more specific error because we don't know the string to match
        expect(subject).to model_have_error_on_field(:data)
      end
    end

    context 'when importing more follows than allowed' do
      let(:import_type) { 'following' }
      let(:import_file) { 'imports.txt' }

      before do
        allow(FollowLimitValidator).to receive(:limit_for_account).with(account).and_return(1)
      end

      it 'has errors' do
        subject.validate
        expect(subject.errors[:data]).to include(I18n.t('users.follow_limit_reached', limit: 1))
      end
    end

    it_behaves_like 'too many CSV rows', 'following', 'imports.txt', 1
    it_behaves_like 'too many CSV rows', 'blocking', 'imports.txt', 1
    it_behaves_like 'too many CSV rows', 'muting', 'imports.txt', 1
    it_behaves_like 'too many CSV rows', 'domain_blocking', 'domain_blocks.csv', 2
    it_behaves_like 'too many CSV rows', 'bookmarks', 'bookmark-imports.txt', 3

    # Importing list of addresses with no headers into various types
    it_behaves_like 'valid import', 'following', 'imports.txt'
    it_behaves_like 'valid import', 'blocking', 'imports.txt'
    it_behaves_like 'valid import', 'muting', 'imports.txt'

    # Importing domain blocks with headers into expected type
    it_behaves_like 'valid import', 'domain_blocking', 'domain_blocks.csv'

    # Importing bookmarks list with no headers into expected type
    it_behaves_like 'valid import', 'bookmarks', 'bookmark-imports.txt'

    # Importing followed accounts with headers into various compatible types
    it_behaves_like 'valid import', 'following', 'following_accounts.csv'
    it_behaves_like 'valid import', 'blocking', 'following_accounts.csv'
    it_behaves_like 'valid import', 'muting', 'following_accounts.csv'

    # Importing domain blocks with headers into incompatible types
    it_behaves_like 'incompatible import type', 'following', 'domain_blocks.csv'
    it_behaves_like 'incompatible import type', 'blocking', 'domain_blocks.csv'
    it_behaves_like 'incompatible import type', 'muting', 'domain_blocks.csv'
    it_behaves_like 'incompatible import type', 'bookmarks', 'domain_blocks.csv'

    # Importing followed accounts with headers into incompatible types
    it_behaves_like 'incompatible import type', 'domain_blocking', 'following_accounts.csv'
    it_behaves_like 'incompatible import type', 'bookmarks', 'following_accounts.csv'
  end

  describe '#guessed_type' do
    shared_examples 'with enough information' do |type, file, original_filename, expected_guess|
      let(:import_file) { file }
      let(:import_type) { type }

      before do
        allow(data).to receive(:original_filename).and_return(original_filename)
      end

      it 'guesses the expected type' do
        expect(subject.guessed_type).to eq expected_guess
      end
    end

    context 'when the headers are enough to disambiguate' do
      it_behaves_like 'with enough information', 'following', 'following_accounts.csv', 'import.csv', :following
      it_behaves_like 'with enough information', 'blocking', 'following_accounts.csv', 'import.csv', :following
      it_behaves_like 'with enough information', 'muting', 'following_accounts.csv', 'import.csv', :following

      it_behaves_like 'with enough information', 'following', 'muted_accounts.csv', 'imports.csv', :muting
      it_behaves_like 'with enough information', 'blocking', 'muted_accounts.csv', 'imports.csv', :muting
      it_behaves_like 'with enough information', 'muting', 'muted_accounts.csv', 'imports.csv', :muting
    end

    context 'when the file name is enough to disambiguate' do
      it_behaves_like 'with enough information', 'following', 'imports.txt', 'following_accounts.csv', :following
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'following_accounts.csv', :following
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'following_accounts.csv', :following

      it_behaves_like 'with enough information', 'following', 'imports.txt', 'follows.csv', :following
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'follows.csv', :following
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'follows.csv', :following

      it_behaves_like 'with enough information', 'following', 'imports.txt', 'blocked_accounts.csv', :blocking
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'blocked_accounts.csv', :blocking
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'blocked_accounts.csv', :blocking

      it_behaves_like 'with enough information', 'following', 'imports.txt', 'blocks.csv', :blocking
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'blocks.csv', :blocking
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'blocks.csv', :blocking

      it_behaves_like 'with enough information', 'following', 'imports.txt', 'muted_accounts.csv', :muting
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'muted_accounts.csv', :muting
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'muted_accounts.csv', :muting

      it_behaves_like 'with enough information', 'following', 'imports.txt', 'mutes.csv', :muting
      it_behaves_like 'with enough information', 'blocking', 'imports.txt', 'mutes.csv', :muting
      it_behaves_like 'with enough information', 'muting', 'imports.txt', 'mutes.csv', :muting
    end
  end

  describe '#likely_mismatched?' do
    shared_examples 'with matching types' do |type, file, original_filename = nil|
      let(:import_file) { file }
      let(:import_type) { type }

      before do
        allow(data).to receive(:original_filename).and_return(original_filename) if original_filename.present?
      end

      it 'returns false' do
        expect(subject.likely_mismatched?).to be false
      end
    end

    shared_examples 'with mismatching types' do |type, file, original_filename = nil|
      let(:import_file) { file }
      let(:import_type) { type }

      before do
        allow(data).to receive(:original_filename).and_return(original_filename) if original_filename.present?
      end

      it 'returns true' do
        expect(subject.likely_mismatched?).to be true
      end
    end

    it_behaves_like 'with matching types', 'following', 'following_accounts.csv'
    it_behaves_like 'with matching types', 'following', 'following_accounts.csv', 'imports.txt'
    it_behaves_like 'with matching types', 'following', 'imports.txt'
    it_behaves_like 'with matching types', 'blocking', 'imports.txt', 'blocks.csv'
    it_behaves_like 'with matching types', 'blocking', 'imports.txt'
    it_behaves_like 'with matching types', 'muting', 'muted_accounts.csv'
    it_behaves_like 'with matching types', 'muting', 'muted_accounts.csv', 'imports.txt'
    it_behaves_like 'with matching types', 'muting', 'imports.txt'
    it_behaves_like 'with matching types', 'domain_blocking', 'domain_blocks.csv'
    it_behaves_like 'with matching types', 'domain_blocking', 'domain_blocks.csv', 'imports.txt'
    it_behaves_like 'with matching types', 'bookmarks', 'bookmark-imports.txt'
    it_behaves_like 'with matching types', 'bookmarks', 'bookmark-imports.txt', 'imports.txt'

    it_behaves_like 'with mismatching types', 'following', 'imports.txt', 'blocks.csv'
    it_behaves_like 'with mismatching types', 'following', 'imports.txt', 'blocked_accounts.csv'
    it_behaves_like 'with mismatching types', 'following', 'imports.txt', 'mutes.csv'
    it_behaves_like 'with mismatching types', 'following', 'imports.txt', 'muted_accounts.csv'
    it_behaves_like 'with mismatching types', 'following', 'muted_accounts.csv'
    it_behaves_like 'with mismatching types', 'following', 'muted_accounts.csv', 'imports.txt'
    it_behaves_like 'with mismatching types', 'blocking', 'following_accounts.csv'
    it_behaves_like 'with mismatching types', 'blocking', 'following_accounts.csv', 'imports.txt'
    it_behaves_like 'with mismatching types', 'blocking', 'muted_accounts.csv'
    it_behaves_like 'with mismatching types', 'blocking', 'muted_accounts.csv', 'imports.txt'
    it_behaves_like 'with mismatching types', 'blocking', 'imports.txt', 'follows.csv'
    it_behaves_like 'with mismatching types', 'blocking', 'imports.txt', 'following_accounts.csv'
    it_behaves_like 'with mismatching types', 'blocking', 'imports.txt', 'mutes.csv'
    it_behaves_like 'with mismatching types', 'blocking', 'imports.txt', 'muted_accounts.csv'
    it_behaves_like 'with mismatching types', 'muting', 'following_accounts.csv'
    it_behaves_like 'with mismatching types', 'muting', 'following_accounts.csv', 'imports.txt'
    it_behaves_like 'with mismatching types', 'muting', 'imports.txt', 'follows.csv'
    it_behaves_like 'with mismatching types', 'muting', 'imports.txt', 'following_accounts.csv'
    it_behaves_like 'with mismatching types', 'muting', 'imports.txt', 'blocks.csv'
    it_behaves_like 'with mismatching types', 'muting', 'imports.txt', 'blocked_accounts.csv'
  end

  describe 'save' do
    shared_examples 'on successful import' do |type, mode, file, expected_rows|
      let(:import_type) { type }
      let(:import_file) { file }
      let(:import_mode) { mode }

      before do
        subject.save
      end

      it 'creates the expected rows' do
        expect(account.bulk_imports.first.rows.pluck(:data)).to match_array(expected_rows)
      end

      it 'creates a BulkImport with expected attributes' do
        bulk_import = account.bulk_imports.first
        expect(bulk_import).to_not be_nil
        expect(bulk_import.type.to_sym).to eq subject.type.to_sym
        expect(bulk_import.original_filename).to eq subject.data.original_filename
        expect(bulk_import.likely_mismatched?).to eq subject.likely_mismatched?
        expect(bulk_import.overwrite?).to eq !!subject.overwrite # rubocop:disable Style/DoubleNegation
        expect(bulk_import.processed_items).to eq 0
        expect(bulk_import.imported_items).to eq 0
        expect(bulk_import.total_items).to eq bulk_import.rows.count
        expect(bulk_import.unconfirmed?).to be true
      end
    end

    it_behaves_like 'on successful import', 'following', 'merge', 'imports.txt', (%w(user@example.com user@test.com).map { |acct| { 'acct' => acct } })
    it_behaves_like 'on successful import', 'following', 'overwrite', 'imports.txt', (%w(user@example.com user@test.com).map { |acct| { 'acct' => acct } })
    it_behaves_like 'on successful import', 'blocking', 'merge', 'imports.txt', (%w(user@example.com user@test.com).map { |acct| { 'acct' => acct } })
    it_behaves_like 'on successful import', 'blocking', 'overwrite', 'imports.txt', (%w(user@example.com user@test.com).map { |acct| { 'acct' => acct } })
    it_behaves_like 'on successful import', 'muting', 'merge', 'imports.txt', (%w(user@example.com user@test.com).map { |acct| { 'acct' => acct } })
    it_behaves_like 'on successful import', 'domain_blocking', 'merge', 'domain_blocks.csv', (%w(bad.domain worse.domain reject.media).map { |domain| { 'domain' => domain } })
    it_behaves_like 'on successful import', 'bookmarks', 'merge', 'bookmark-imports.txt', (%w(https://example.com/statuses/1312 https://local.com/users/foo/statuses/42 https://unknown-remote.com/users/bar/statuses/1 https://example.com/statuses/direct).map { |uri| { 'uri' => uri } })

    it_behaves_like 'on successful import', 'following', 'merge', 'following_accounts.csv', [
      { 'acct' => 'user@example.com', 'show_reblogs' => true, 'notify' => false, 'languages' => nil },
      { 'acct' => 'user@test.com', 'show_reblogs' => true, 'notify' => true, 'languages' => ['en', 'fr'] },
    ]

    it_behaves_like 'on successful import', 'muting', 'merge', 'muted_accounts.csv', [
      { 'acct' => 'user@example.com', 'hide_notifications' => true },
      { 'acct' => 'user@test.com', 'hide_notifications' => false },
    ]

    # Based on the bug report 20571 where UTF-8 encoded domains were rejecting import of their users
    #
    # https://github.com/mastodon/mastodon/issues/20571
    it_behaves_like 'on successful import', 'following', 'merge', 'utf8-followers.txt', [{ 'acct' => 'nare@թութ.հայ' }]
  end
end
