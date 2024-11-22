# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactComponentHelper do
  describe 'react_component' do
    context 'with no block passed in' do
      let(:result) { helper.react_component('name', { one: :two }) }

      it 'returns a tag with data attributes' do
        expect(parsed_html.div['data-component']).to eq('Name')
        expect(parsed_html.div['data-props']).to eq('{"one":"two"}')
      end
    end

    context 'with a block passed in' do
      let(:result) do
        helper.react_component('name', { one: :two }) do
          helper.content_tag(:nav, 'ok')
        end
      end

      it 'returns a tag with data attributes' do
        expect(parsed_html.div['data-component']).to eq('Name')
        expect(parsed_html.div['data-props']).to eq('{"one":"two"}')
        expect(parsed_html.div.nav.content).to eq('ok')
      end
    end
  end

  describe 'react_admin_component' do
    let(:result) { helper.react_admin_component('name', { one: :two }) }

    it 'returns a tag with data attributes' do
      expect(parsed_html.div['data-admin-component']).to eq('Name')
      expect(parsed_html.div['data-props']).to eq('{"one":"two"}')
    end
  end

  private

  def parsed_html
    Nokogiri::Slop(result)
  end
end
