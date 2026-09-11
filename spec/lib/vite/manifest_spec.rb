# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Manifest do
  subject { described_class.new(config:, logger:) }

  let(:config) do
    Vite::Config.new({
      auto_build: false,
      manifest_path: manifest_path,
      manifest_assets_path: manifest_assets_path,
    })
  end

  let(:logger) { Logger.new(StringIO.new) }

  let(:manifest_path) { manifest_file.to_path }
  let(:manifest_assets_path) { manifest_assets_file.to_path }

  let(:manifest_file) { file_fixture('vite-manifest.json') }
  let(:manifest_assets_file) { file_fixture('vite-manifest-assets.json') }

  describe '#fetch' do
    it 'gets assets from manifest_assets' do
      entry = subject.fetch('icons/main.png')
      expect(entry[:file]).to eq('assets/main-abc.png')
      expect(entry[:integrity]).to eq('abc-9')
    end

    it 'gets locales' do
      entry = subject.fetch('mastodon/locales/en-GB.json')
      expect(entry[:file]).to eq('intl/en-GB.js')
      expect(entry[:integrity]).to eq('abc-1')
    end

    it 'gets virtual assets' do
      entry = subject.fetch('polyfills', type: :virtual)
      expect(entry[:file]).to eq('polyfills.js')
      expect(entry[:integrity]).to eq('abc-8')
    end

    it 'gets stylesheets' do
      entry = subject.fetch('styles/entrypoints/inert.scss')
      expect(entry[:file]).to eq('assets/inert-xyz.css')
      expect(entry[:integrity]).to eq('abc-10')
    end

    context 'when assets have dependencies' do
      let(:entry) { subject.fetch('entrypoints/application.ts') }

      it 'gets the entrypoint' do
        expect(entry[:file]).to eq('application.js')
        expect(entry[:integrity]).to eq('abc-2')
      end

      it 'resolves all the imports from bottom to top without duplicates' do
        imports = subject.imports_for(entry).pluck(:file)
        expect(imports).to eq(%w(no-deps.js dep-1-1.js dep-1-2.js dep-1.js dep-2.js))
      end

      it 'resolves all the stylesheets from bottom to top without duplicates' do
        stylesheets = subject.stylesheets_for(entry).pluck(:file)
        expect(stylesheets).to eq(%w(assets/dep-1-1.css assets/dep-1.css assets/dep-2.css assets/main.css assets/unlisted.css))
      end

      context 'when another entrypoint has the same dependencies' do
        let(:entry) { subject.fetch('entrypoints/admin.ts') }

        it 'resolves all the imports from bottom to top without duplicates' do
          imports = subject.imports_for(entry).pluck(:file)
          expect(imports).to eq(%w(no-deps.js dep-1-1.js dep-1-2.js dep-1.js dep-2.js dep-3.js))
        end

        it 'resolves all the stylesheets from bottom to top without duplicates' do
          stylesheets = subject.stylesheets_for(entry).pluck(:file)
          expect(stylesheets).to eq(%w(assets/dep-1-1.css assets/dep-1.css assets/dep-2.css assets/main.css assets/unlisted.css))
        end
      end
    end
  end

  describe 'fetch!' do
    it 'raises an error on missing entries' do
      expect { subject.fetch!('missing.ts') }.to raise_error(Vite::Manifest::MissingEntryError)
    end
  end

  describe '#load' do
    it 'has one reference per entrypoint' do
      subject.load

      entries = subject.entries
      expect(entries.keys.count).to eq(6)
    end

    it 'only keeps track of dependencies' do
      subject.load

      pool = subject.pool
      expect(pool.count).to eq(11)
      # This file is present in the manifest but not referenced by any entrypoint
      expect(pool.find { |entry| entry[:file] == 'package.js' }).to be_nil
    end

    context 'when the manifest is missing' do
      let(:manifest_path) { 'tmp/missing.json' }

      it 'raises an error' do
        expect { subject.load }.to raise_error(Vite::Manifest::MissingManifestError)
      end

      context 'when auto_build is enabled' do
        let(:config) do
          Vite::Config.new({
            auto_build: true,
            manifest_path: manifest_path,
            manifest_assets_path: manifest_assets_path,
          })
        end

        let(:manifest_path) { Rails.root.join('tmp', 'vite-manifest.json') }

        let(:builder) { instance_double(Vite::Builder) }

        after do
          FileUtils.rm_f(manifest_path)
        end

        it 'builds on missing file' do
          allow(Vite::Builder).to receive(:new).and_return(builder)
          allow(builder).to receive(:build) do
            # Create an empty file
            File.write(manifest_path, '{}')
          end

          expect { subject.load }.to_not raise_error
        end
      end
    end
  end
end
