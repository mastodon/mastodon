# frozen_string_literal: true

require 'rails_helper'

describe DomainAllow do
  describe 'Validations' do
    it 'is invalid without a domain' do
      domain_allow = Fabricate.build(:domain_allow, domain: nil)
      domain_allow.valid?
      expect(domain_allow).to model_have_error_on_field(:domain)
    end

    it 'is invalid if the same normalized domain already exists' do
      _domain_allow = Fabricate(:domain_allow, domain: 'にゃん')
      domain_allow_with_normalized_value = Fabricate.build(:domain_allow, domain: 'xn--r9j5b5b')
      domain_allow_with_normalized_value.valid?
      expect(domain_allow_with_normalized_value).to model_have_error_on_field(:domain)
    end
  end
end
