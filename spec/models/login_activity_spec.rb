# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginActivity do
  it_behaves_like 'BrowserDetection'

  describe 'Associations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :login_activity }

    it { is_expected.to define_enum_for(:authentication_method).backed_by_column_of_type(:string) }
  end

  describe 'Callbacks' do
    describe 'setting IP from request attributes' do
      subject { Fabricate :login_activity, ip: nil }

      before { Current.ip_address = ip }

      let(:ip) { '123.123.123.123' }

      it 'sets IP address from current attributes' do
        expect(subject)
          .to have_attributes(ip: IPAddr.new(ip))
      end
    end

    describe 'setting user agent from request attributes' do
      subject { Fabricate :login_activity, user_agent: nil }

      before { Current.user_agent = user_agent }

      let(:user_agent) { 'Browser 1.2.3' }

      it 'sets user agent from current attributes' do
        expect(subject)
          .to have_attributes(user_agent:)
      end
    end
  end
end
