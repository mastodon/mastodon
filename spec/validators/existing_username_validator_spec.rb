# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExistingUsernameValidator do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :contact, :friends

      def self.name = 'Record'

      validates :contact, existing_username: true
      validates :friends, existing_username: { multiple: true }
    end
  end

  context 'with a nil value' do
    it { is_expected.to allow_value(nil).for(:contact) }
  end

  context 'when there are no accounts' do
    it { is_expected.to_not allow_value('user@example.com').for(:contact).with_message(I18n.t('existing_username_validator.not_found')) }
  end

  context 'when there are accounts' do
    before { Fabricate(:account, domain: 'example.com', username: 'user') }

    context 'when the value does not match' do
      it { is_expected.to_not allow_value('friend@other.host').for(:contact).with_message(I18n.t('existing_username_validator.not_found')) }

      context 'when multiple is true' do
        it { is_expected.to_not allow_value('friend@other.host').for(:friends).with_message(I18n.t('existing_username_validator.not_found_multiple', usernames: 'friend@other.host')) }
      end
    end

    context 'when the value does match' do
      it { is_expected.to allow_value('user@example.com').for(:contact) }

      it { is_expected.to allow_value('user@example.com').for(:friends) }
    end
  end
end
