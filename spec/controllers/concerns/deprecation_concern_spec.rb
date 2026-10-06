# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeprecationConcern do
  render_views

  controller(ApplicationController) do
    include DeprecationConcern # rubocop:disable RSpec/DescribedClass

    deprecate_api '2026-08-03', sunset: '2026-10-01'

    def deprecated
      render plain: 'deprecated'
    end
  end

  before do
    routes.draw do
      get 'deprecated' => 'anonymous#deprecated'
    end
  end

  context 'with response headers' do
    it 'adds Deprecation header' do
      get :deprecated

      expect(response.body).to eq('deprecated')
      expect(response.headers['Deprecation']).to eq('@1785715200')
    end

    it 'adds Sunset header' do
      get :deprecated

      expect(response.headers['Sunset']).to eq('Thu, 01 Oct 2026 00:00:00 GMT')
    end
  end

  context 'with OpenTelemetry traces' do
    let(:span) { instance_double(OpenTelemetry::Trace::Span) }

    before do
      allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
      allow(span).to receive(:recording?).and_return(true)
      allow(span).to receive(:set_attribute)
    end

    it 'adds a deprecation attribute request span' do
      get :deprecated

      expect(span).to have_received(:set_attribute).with('app.endpoint.deprecated', true)
    end
  end
end
