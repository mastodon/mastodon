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
end
