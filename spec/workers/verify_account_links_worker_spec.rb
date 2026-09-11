# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerifyAccountLinksWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    subject { worker.perform(account_id) }

    context 'with invalid account' do
      let(:account_id) { 123_123_123 }

      it 'runs without error for missing record' do
        expect { subject }
          .to_not raise_error
      end
    end

    context 'with an account that has fields' do
      let(:account) { Fabricate :account }
      let(:account_id) { account.id }
      let(:url) { ActivityPub::TagManager.instance.url_for(account) }

      before do
        stub_request(:get, 'https://linkedin.com/user')
          .to_return(status: 200, body: <<~HTML)
            <a rel="me" href="#{url}">me</a>
          HTML
        account.fields = [{ name: 'GitHub', value: 'https://github.com/user', verified_at: 2.days.ago }, { name: 'LinkedIn', value: 'https://linkedin.com/user' }]
        account.save!
      end

      it 'verifies the fields and updates the account' do
        expect { subject }
          .to(change { account.reload.updated_at })
        expect(account.fields)
          .to include(have_attributes(name: 'LinkedIn', verified_at: be_present))
      end
    end
  end
end
