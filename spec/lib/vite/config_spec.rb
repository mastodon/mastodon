# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Config do
  subject { described_class.new }

  describe '#backend' do
    it 'returns the full dev server URL' do
      expect(subject.backend).to eq('http://localhost:5173')
    end
  end

  describe '#copy_from' do
    let(:other) do
      {
        host: '127.0.0.1',
        port: 3036,
        https: true,
        base_path: '/specs/',
        tag_strategies: ['dev_server'],
        manifest_path: 'public/specs/.vite/manifest.json',
        manifest_assets_path: 'public/specs/.vite/manifest-assets.json',
        auto_build: true,
        build_command: 'echo "spec config"',
      }
    end

    it 'copies data from a hash' do
      subject.copy_from(other)

      expect(subject.host).to eq(other[:host])
      expect(subject.port).to eq(other[:port])
      expect(subject.https?).to eq(other[:https])
      expect(subject.base_path).to eq(other[:base_path])
      expect(subject.tag_strategies).to eq([:dev_server])
      expect(subject.manifest_path).to eq(other[:manifest_path])
      expect(subject.manifest_assets_path).to eq(other[:manifest_assets_path])
      expect(subject.auto_build?).to eq(other[:auto_build])
      expect(subject.build_command).to eq(other[:build_command])
    end
  end
end
