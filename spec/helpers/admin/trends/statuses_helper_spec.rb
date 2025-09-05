# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Trends::StatusesHelper do
  describe '.one_line_preview' do
    before do
      allow(helper).to receive(:current_user).and_return(Fabricate.build(:user))
    end

    context 'with a local status' do
      let(:status) { Fabricate.build(:status, text: 'Test local status') }

      it 'renders a correct preview text' do
        result = helper.one_line_preview(status)

        expect(result).to eq 'Test local status'
      end
    end

    context 'with a remote status' do
      let(:status) { Fabricate.build(:status, uri: 'https://sfd.sdf', text: '<html><body><p>Test remote status</p><p>text</p></body></html>') }

      it 'renders a correct preview text' do
        result = helper.one_line_preview(status)

        expect(result).to eq 'Test remote status'
      end
    end

    context 'with a remote status that has excessive attributes' do
      let(:attr_limit) { Nokogiri::Gumbo::DEFAULT_MAX_ATTRIBUTES * 2 }
      let(:html) { "<html><body #{(1..attr_limit).map { |x| "attr-#{x}" }.join(' ')}><p>text</p></body></html>" }

      let(:status) { Fabricate.build(:status, uri: 'https://host.example', text: html) }

      it 'renders a correct preview text' do
        result = helper.one_line_preview(status)

        expect(result).to eq ''
      end
    end

    context 'with a status that has empty text' do
      let(:status) { Fabricate.build(:status, text: '') }

      it 'renders a correct preview text' do
        result = helper.one_line_preview(status)

        expect(result).to eq ''
      end
    end

    context 'with a status that has emoji' do
      before { Fabricate(:custom_emoji, shortcode: 'florpy') }

      let(:status) { Fabricate.build(:status, text: 'hello there :florpy:') }

      it 'renders a correct preview text' do
        result = helper.one_line_preview(status)

        expect(result).to match 'hello there'
        expect(result).to match '<img rel="emoji"'
      end
    end
  end
end
