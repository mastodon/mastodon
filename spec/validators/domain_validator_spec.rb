# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainValidator do
  subject { record_class.new }

  context 'with no options' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        def self.name = 'Record'

        attr_accessor :domain

        validates :domain, domain: true
      end
    end

    context 'with a nil value' do
      it { is_expected.to allow_value(nil).for(:domain) }
    end

    context 'with a valid domain' do
      it { is_expected.to allow_value('host.example').for(:domain) }
    end

    context 'with a domain that is too long' do
      let(:long_hostname) { "#{'a' * 300}.com" }

      it { is_expected.to_not allow_value(long_hostname).for(:domain) }
    end

    context 'with a domain with an empty segment' do
      it { is_expected.to_not allow_value('.example.com').for(:domain) }
    end

    context 'with a domain with an invalid character' do
      it { is_expected.to_not allow_value('*.example.com').for(:domain) }
    end

    context 'with a domain that would fail parsing' do
      it { is_expected.to_not allow_value('/').for(:domain) }
    end
  end

  context 'with acct option' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        def self.name = 'Record'

        attr_accessor :acct

        validates :acct, domain: { acct: true }
      end
    end

    context 'with a nil value' do
      it { is_expected.to allow_value(nil).for(:acct) }
    end

    context 'with no domain' do
      it { is_expected.to allow_value('hoge_123').for(:acct) }
    end

    context 'with a valid domain' do
      it { is_expected.to allow_value('hoge_123@example.com').for(:acct) }
    end

    context 'with an invalid domain' do
      it { is_expected.to_not allow_value('hoge_123@.example.com').for(:acct) }
    end
  end
end
