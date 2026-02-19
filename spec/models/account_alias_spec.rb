# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountAlias do
  describe 'Normalizations' do
    describe 'acct' do
      it { is_expected.to normalize(:acct).from('  @username@domain  ').to('username@domain') }
    end
  end

  describe 'Validations' do
    subject { described_class.new(account:) }

    let(:account) { Fabricate :account }

    it { is_expected.to_not allow_values(nil, '').for(:uri).against(:acct).with_message(not_found_message) }

    it { is_expected.to_not allow_values(account_uri).for(:uri).against(:acct).with_message(self_move_message) }

    def account_uri
      ActivityPub::TagManager.instance.uri_for(subject.account)
    end

    def not_found_message
      I18n.t('migrations.errors.not_found')
    end

    def self_move_message
      I18n.t('migrations.errors.move_to_self')
    end
  end
end
