# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Config do
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
        out_dir: 'public/specs',
        cache_dir: 'tmp/.vite',
      }
    end

    before do
      subject.copy_from(other)
    end

    it 'copies server, manifest, build, and asset management data from a hash', :aggregate_failures do
      expect(subject)
        .to have_attributes(
          host: other[:host],
          port: other[:port],
          https?: other[:https],
          base_path: other[:base_path],
          tag_strategies: [:dev_server],
          manifest_path: other[:manifest_path],
          manifest_assets_path: other[:manifest_assets_path],
          auto_build?: other[:auto_build],
          build_command: other[:build_command],
          out_dir: other[:out_dir],
          cache_dir: other[:cache_dir]
        )
    end
  end
end
