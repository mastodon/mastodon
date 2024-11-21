# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountModerationNotesHelper do
  include AccountsHelper

  describe '#admin_account_link_to' do
    subject { helper.admin_account_link_to(account) }

    context 'when Account is nil' do
      let(:account) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with account' do
      let(:account) { Fabricate(:account) }

      it 'returns a labeled avatar link to the account' do
        expect(parsed_html.a[:href]).to eq admin_account_path(account.id)
        expect(parsed_html.a[:class]).to eq 'name-tag'
        expect(parsed_html.a.span.text).to eq account.acct
      end
    end
  end

  describe '#admin_account_inline_link_to' do
    subject { helper.admin_account_inline_link_to(account) }

    context 'when Account is nil' do
      let(:account) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with account' do
      let(:account) { Fabricate(:account) }

      it 'returns an inline link to the account' do
        expect(parsed_html.a[:href]).to eq admin_account_path(account.id)
        expect(parsed_html.a[:class]).to eq 'inline-name-tag'
        expect(parsed_html.a.span.text).to eq account.acct
      end
    end
  end

  def parsed_html
    Nokogiri::Slop(subject)
  end
end
