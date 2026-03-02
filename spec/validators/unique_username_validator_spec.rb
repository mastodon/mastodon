# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UniqueUsernameValidator do
  subject { Fabricate.build :account, username: 'abcdef', domain: }

  context 'when local account' do
    let(:domain) { nil }

    context 'when record is persisted and checking own name' do
      before { subject.save }

      it { is_expected.to allow_value(subject.username).for(:username) }
    end

    context 'when username case insensitive in use already' do
      before { Fabricate :account, username: 'ABCdef' }

      it { is_expected.to_not allow_value('abcDEF').for(:username).with_message(:taken) }
    end

    context 'when username on remote account is in use' do
      before { Fabricate :account, username: 'ABCdef', domain: 'host.example' }

      it { is_expected.to allow_value('abcDEF').for(:username) }
    end
  end

  context 'when remote account' do
    let(:domain) { 'host.example' }

    context 'when record is persisted and checking own name' do
      before { subject.save }

      it { is_expected.to allow_value('abcdef').for(:username) }
    end

    context 'when username case insensitive in use already' do
      before { Fabricate :account, username: 'ABCdef', domain: 'host.example' }

      it { is_expected.to_not allow_value('abcDEF').for(:username) }
    end

    context 'when domain case insensitive in use already' do
      before { Fabricate :account, username: 'ABCdef', domain: 'HOST.EXAMPLE' }

      it { is_expected.to_not allow_value('abcDEF').for(:username) }
    end

    context 'when same username on other domain is in use already' do
      before { Fabricate :account, username: 'abcdef', domain: 'other.example' }

      it { is_expected.to allow_value('abcdef').for(:username) }
    end
  end

  context 'when account has blank username' do
    subject { described_class.new.validate(account) }

    let(:account) { Fabricate.build :account, username: nil }

    it { is_expected.to be_nil }
  end
end
