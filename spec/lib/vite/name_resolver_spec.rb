# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::NameResolver do
  subject { described_class.new(config:) }

  let(:config) { Struct.new(:base_path).new('/specs/') }

  describe '#full_path' do
    context 'with an entrypoint' do
      it 'returns full path' do
        expect(subject.full_path('common.ts')).to eq('/specs/entrypoints/common.ts')
      end
    end

    context 'with a nested path' do
      it 'returns full path' do
        expect(subject.full_path('styles/application.scss')).to eq('/specs/styles/application.scss')
      end
    end
  end

  describe '#entrypoint_path' do
    context 'with an entrypoint' do
      it 'returns entrypoint path' do
        expect(subject.entrypoint_path('common.ts')).to eq('entrypoints/common.ts')
      end
    end

    context 'with a nested path' do
      it 'returns entrypoint path' do
        expect(subject.entrypoint_path('styles/application.scss')).to eq('styles/application.scss')
      end
    end
  end

  describe '#bundle_path' do
    context 'with an entrypoint' do
      it 'returns bundle path' do
        expect(subject.bundle_path('entrypoints/common.ts')).to eq('/specs/entrypoints/common.ts')
      end
    end

    context 'with a nested path' do
      it 'returns bundle path' do
        expect(subject.bundle_path('styles/application.scss')).to eq('/specs/styles/application.scss')
      end
    end
  end
end
