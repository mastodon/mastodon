# frozen_string_literal: true

require 'rails_helper'

describe ReactHelper do
  describe 'react_component' do
    context 'with no block passed in' do
      let(:result) { helper.react_component('name', { one: :two }) }
      let(:html) { Nokogiri::Slop(result) }

      it 'returns a tag with data attributes' do
        expect(html.div['data-component']).to eq('Name')
        expect(html.div['data-props']).to eq('{"one":"two"}')
      end
    end

    context 'with a block passed in' do
      let(:result) do
        helper.react_component('name', { one: :two }) do
          helper.content_tag(:nav, 'ok')
        end
      end
      let(:html) { Nokogiri::Slop(result) }

      it 'returns a tag with data attributes' do
        expect(html.div['data-component']).to eq('Name')
        expect(html.div['data-props']).to eq('{"one":"two"}')
        expect(html.div.nav.content).to eq('ok')
      end
    end
  end

  describe 'react_admin_component' do
    let(:result) { helper.react_admin_component('name', { one: :two }) }
    let(:html) { Nokogiri::Slop(result) }

    it 'returns a tag with data attributes' do
      expect(html.div['data-admin-component']).to eq('Name')
      expect(html.div['data-props']).to eq('{"locale":"en","one":"two"}')
    end
  end
end
