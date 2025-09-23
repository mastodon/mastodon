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
end
