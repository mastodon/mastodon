# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainAllow do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:domain) }

    context 'when a normalized domain exists' do
      before { Fabricate(:domain_allow, domain: 'にゃん') }

      it { is_expected.to_not allow_value('xn--r9j5b5b').for(:domain) }
    end
  end

  describe '.allowed_domains' do
    subject { described_class.allowed_domains }

    context 'without domain allows' do
      it { is_expected.to be_an(Array).and(be_empty) }
    end

    context 'with domain allows' do
      let!(:allowed_domain) { Fabricate :domain_allow }
      let!(:other_allowed_domain) { Fabricate :domain_allow }

      it { is_expected.to contain_exactly(allowed_domain.domain, other_allowed_domain.domain) }
    end
  end

  describe '.rule_for' do
    subject { described_class.rule_for(domain) }

    let(:domain) { 'host.example' }

    context 'with no records' do
      it { is_expected.to be_nil }
    end

    context 'with matching record' do
      let!(:domain_allow) { Fabricate :domain_allow, domain: }

      it { is_expected.to eq(domain_allow) }
    end

    context 'when called with non normalized string' do
      let!(:domain_allow) { Fabricate :domain_allow, domain: }
      let(:domain) { '  HOST.example/' }

      it { is_expected.to eq(domain_allow) }
    end
  end
end
