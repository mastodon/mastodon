# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarkFolder do
  describe 'Associations' do
    it { is_expected.to have_many(:bookmarks).with_foreign_key('folder_id').dependent(:nullify) }
  end

  describe 'Validations' do
    subject { Fabricate.build :bookmark_folder }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_LENGTH_LIMIT) }

    context 'when account has hit max folder limit' do
      let(:account) { Fabricate :account }

      before do
        stub_const 'BookmarkFolder::PER_ACCOUNT_LIMIT', 1

        Fabricate(:bookmark_folder, account: account)
      end

      context 'when creating a new folder' do
        it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('bookmark_folders.errors.limit')) }
      end

      context 'when updating an existing folder' do
        before { subject.save(validate: false) }

        it { is_expected.to allow_value(account).for(:account).against(:base) }
      end
    end
  end
end
