# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

RSpec.describe Mastodon::CLI::Maintenance do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#fix_duplicates' do
    let(:action) { :fix_duplicates }

    context 'when the database version is too old' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2000_01_01_000000) # Earlier than minimum
      end

      it 'Exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /is too old/)
      end
    end

    context 'when the database version is too new and the user does not continue' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2100_01_01_000000) # Later than maximum
        allow(cli.shell).to receive(:yes?).with('Continue anyway? (Yes/No)').and_return(false).once
      end

      it 'Exits with error message' do
        expect { subject }
          .to output_results('more recent')
          .and raise_error(Thor::Error, /more recent/)
      end
    end

    context 'when Sidekiq is running' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2022_01_01_000000) # Higher than minimum, lower than maximum
        allow(Sidekiq::ProcessSet).to receive(:new).and_return [:process]
      end

      it 'Exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /Sidekiq is running/)
      end
    end

    context 'when requirements are met' do
      before do
        allow(ActiveRecord::Migrator).to receive(:current_version).and_return(2023_08_22_081029) # The latest migration before the cutoff
        agree_to_backup_warning
      end

      context 'with duplicate accounts' do
        before do
          prepare_duplicate_data
          choose_local_account_to_keep
        end

        let(:duplicate_account_username) { 'username' }
        let(:duplicate_account_domain) { 'host.example' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating accounts',
              'Multiple local accounts were found for',
              'Restoring index_accounts_on_username_and_domain_lower',
              'Reindexing textual indexes on accounts…',
              'Finished!'
            )
            .and change(duplicate_remote_accounts, :count).from(2).to(1)
            .and change(duplicate_local_accounts, :count).from(2).to(1)
        end

        def duplicate_remote_accounts
          Account.where(username: duplicate_account_username, domain: duplicate_account_domain)
        end

        def duplicate_local_accounts
          Account.where(username: duplicate_account_username, domain: nil)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :accounts, name: :index_accounts_on_username_and_domain_lower
          duplicate_record(:account, username: duplicate_account_username, domain: duplicate_account_domain)
          duplicate_record(:account, username: duplicate_account_username, domain: nil)
        end

        def choose_local_account_to_keep
          allow(cli.shell)
            .to receive(:ask)
            .with(/Account to keep unchanged/, anything)
            .and_return('0')
            .once
        end
      end

      context 'with duplicate users on email' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_email) { 'duplicate@example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(email: duplicate_email)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :email
          duplicate_record(:user, email: duplicate_email)
        end
      end

      context 'with duplicate users on confirmation_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_confirmation_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting confirmation token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(confirmation_token: duplicate_confirmation_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :confirmation_token
          duplicate_record(:user, confirmation_token: duplicate_confirmation_token)
        end
      end

      context 'with duplicate users on reset_password_token' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_reset_password_token) { '123ABC' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating user records',
              'Unsetting password reset token',
              'Restoring users indexes',
              'Finished!'
            )
            .and change(duplicate_users, :count).from(2).to(1)
        end

        def duplicate_users
          User.where(reset_password_token: duplicate_reset_password_token)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :users, :reset_password_token
          duplicate_record(:user, reset_password_token: duplicate_reset_password_token)
        end
      end

      context 'with duplicate account_domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_domain) { 'example.host' }
        let(:account) { Fabricate(:account) }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Removing duplicate account domain blocks',
              'Restoring account domain blocks indexes',
              'Finished!'
            )
            .and change(duplicate_account_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_account_domain_blocks
          AccountDomainBlock.where(account: account, domain: duplicate_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :account_domain_blocks, [:account_id, :domain]
          duplicate_record(:account_domain_block, account: account, domain: duplicate_domain)
        end
      end

      context 'with duplicate announcement_reactions' do
        before do
          prepare_duplicate_data
        end

        let(:account) { Fabricate(:account) }
        let(:announcement) { Fabricate(:announcement) }
        let(:name) { Fabricate(:custom_emoji).shortcode }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Removing duplicate announcement reactions',
              'Restoring announcement_reactions indexes',
              'Finished!'
            )
            .and change(duplicate_announcement_reactions, :count).from(2).to(1)
        end

        def duplicate_announcement_reactions
          AnnouncementReaction.where(account: account, announcement: announcement, name: name)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :announcement_reactions, [:account_id, :announcement_id, :name]
          duplicate_record(:announcement_reaction, account: account, announcement: announcement, name: name)
        end
      end

      context 'with duplicate conversations' do
        before do
          prepare_duplicate_data
        end

        let(:uri) { 'https://example.host/path' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating conversations',
              'Restoring conversations indexes',
              'Finished!'
            )
            .and change(duplicate_conversations, :count).from(2).to(1)
        end

        def duplicate_conversations
          Conversation.where(uri: uri)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :conversations, :uri
          duplicate_record(:conversation, uri: uri)
        end
      end

      context 'with duplicate custom_emojis' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_shortcode) { 'wowzers' }
        let(:duplicate_domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating custom_emojis',
              'Restoring custom_emojis indexes',
              'Finished!'
            )
            .and change(duplicate_custom_emojis, :count).from(2).to(1)
        end

        def duplicate_custom_emojis
          CustomEmoji.where(shortcode: duplicate_shortcode, domain: duplicate_domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :custom_emojis, [:shortcode, :domain]
          duplicate_record(:custom_emoji, shortcode: duplicate_shortcode, domain: duplicate_domain)
        end
      end

      context 'with duplicate custom_emoji_categories' do
        before do
          prepare_duplicate_data
        end

        let(:duplicate_name) { 'name_value' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating custom_emoji_categories',
              'Restoring custom_emoji_categories indexes',
              'Finished!'
            )
            .and change(duplicate_custom_emoji_categories, :count).from(2).to(1)
        end

        def duplicate_custom_emoji_categories
          CustomEmojiCategory.where(name: duplicate_name)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :custom_emoji_categories, :name
          duplicate_record(:custom_emoji_category, name: duplicate_name)
        end
      end

      context 'with duplicate domain_allows' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating domain_allows',
              'Restoring domain_allows indexes',
              'Finished!'
            )
            .and change(duplicate_domain_allows, :count).from(2).to(1)
        end

        def duplicate_domain_allows
          DomainAllow.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :domain_allows, :domain
          duplicate_record(:domain_allow, domain: domain)
        end
      end

      context 'with duplicate domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating domain_blocks',
              'Restoring domain_blocks indexes',
              'Finished!'
            )
            .and change(duplicate_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_domain_blocks
          DomainBlock.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :domain_blocks, :domain
          duplicate_record(:domain_block, domain: domain)
        end
      end

      context 'with duplicate email_domain_blocks' do
        before do
          prepare_duplicate_data
        end

        let(:domain) { 'example.host' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating email_domain_blocks',
              'Restoring email_domain_blocks indexes',
              'Finished!'
            )
            .and change(duplicate_email_domain_blocks, :count).from(2).to(1)
        end

        def duplicate_email_domain_blocks
          EmailDomainBlock.where(domain: domain)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :email_domain_blocks, :domain
          duplicate_record(:email_domain_block, domain: domain)
        end
      end

      context 'with duplicate media_attachments' do
        before do
          prepare_duplicate_data
        end

        let(:shortcode) { 'codenam' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating media_attachments',
              'Restoring media_attachments indexes',
              'Finished!'
            )
            .and change(duplicate_media_attachments, :count).from(2).to(1)
        end

        def duplicate_media_attachments
          MediaAttachment.where(shortcode: shortcode)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :media_attachments, :shortcode
          duplicate_record(:media_attachment, shortcode: shortcode)
        end
      end

      context 'with duplicate preview_cards' do
        before do
          prepare_duplicate_data
        end

        let(:url) { 'https://example.host/path' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating preview_cards',
              'Restoring preview_cards indexes',
              'Finished!'
            )
            .and change(duplicate_preview_cards, :count).from(2).to(1)
        end

        def duplicate_preview_cards
          PreviewCard.where(url: url)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :preview_cards, :url
          duplicate_record(:preview_card, url: url)
        end
      end

      context 'with duplicate statuses' do
        before do
          prepare_duplicate_data
        end

        let(:uri) { 'https://example.host/path' }
        let(:account) { Fabricate(:account) }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating statuses',
              'Restoring statuses indexes',
              'Finished!'
            )
            .and change(duplicate_statuses, :count).from(2).to(1)
        end

        def duplicate_statuses
          Status.where(uri: uri)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :statuses, :uri
          Fabricate(:status, account: account, uri: uri)
          duplicate = Fabricate.build(:status, account: account, uri: uri)
          duplicate.save(validate: false)
          Fabricate(:status_pin, account: account, status: duplicate)
          Fabricate(:status, in_reply_to_id: duplicate.id)
          Fabricate(:status, reblog_of_id: duplicate.id)
        end
      end

      context 'with duplicate tags' do
        before do
          prepare_duplicate_data
        end

        let(:name) { 'tagname' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating tags',
              'Restoring tags indexes',
              'Finished!'
            )
            .and change(duplicate_tags, :count).from(2).to(1)
        end

        def duplicate_tags
          Tag.where(name: name)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :tags, name: 'index_tags_on_name_lower_btree'
          duplicate_record(:tag, name: name)
        end
      end

      context 'with duplicate webauthn_credentials' do
        before do
          prepare_duplicate_data
        end

        let(:external_id) { '123_123_123' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating webauthn_credentials',
              'Restoring webauthn_credentials indexes',
              'Finished!'
            )
            .and change(duplicate_webauthn_credentials, :count).from(2).to(1)
        end

        def duplicate_webauthn_credentials
          WebauthnCredential.where(external_id: external_id)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :webauthn_credentials, :external_id
          duplicate_record(:webauthn_credential, external_id: external_id)
        end
      end

      context 'with duplicate webhooks' do
        before do
          prepare_duplicate_data
        end

        let(:url) { 'https://example.host/path' }

        it 'runs the deduplication process' do
          expect { subject }
            .to output_results(
              'Deduplicating webhooks',
              'Restoring webhooks indexes',
              'Finished!'
            )
            .and change(duplicate_webhooks, :count).from(2).to(1)
        end

        def duplicate_webhooks
          Webhook.where(url: url)
        end

        def prepare_duplicate_data
          ActiveRecord::Base.connection.remove_index :webhooks, :url
          duplicate_record(:webhook, url: url)
        end
      end

      def duplicate_record(fabricator, options = {})
        Fabricate(fabricator, options)
        Fabricate.build(fabricator, options).save(validate: false)
      end

      def agree_to_backup_warning
        allow(cli.shell)
          .to receive(:yes?)
          .with('Continue? (Yes/No)')
          .and_return(true)
          .once
      end
    end
  end
end
