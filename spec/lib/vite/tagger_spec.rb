# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Tagger do
  include RSpec::Rails::HelperExampleGroup

  subject { described_class.new(config:, manifest:, dev_server:) }

  let(:manifest) { Vite::Manifest.new(config:, logger:) }

  let(:logger) { Logger.new(StringIO.new) }

  let(:manifest_path) { manifest_file.to_path }
  let(:manifest_assets_path) { manifest_assets_file.to_path }

  let(:manifest_file) { file_fixture('vite-manifest.json') }
  let(:manifest_assets_file) { file_fixture('vite-manifest-assets.json') }

  let(:nonce) { 'hoGYqEChtkb4m4rpaLV1ng==' }

  context 'with :dev_server strategy' do
    let(:config) do
      Vite::Config.new({
        auto_build: false,
        manifest_path: manifest_path,
        manifest_assets_path: manifest_assets_path,
        base_path: '/packs-dev/',
        tag_strategies: [:dev_server],
      })
    end

    let(:dev_server) do
      Class.new do
        def self.running?
          true
        end
      end
    end

    describe '#vite_client_tag' do
      it 'returns @vite/client tag' do
        tag = subject.vite_client_tag(helper)
        expect(tag.to_s).to eq('<script src="/packs-dev/@vite/client" crossorigin="anonymous" type="module"></script>')
      end
    end

    describe '#vite_react_refresh_tag' do
      let(:react_refresh) do
        <<~JAVASCRIPT.html_safe
          import RefreshRuntime from '/packs-dev/@react-refresh'
          RefreshRuntime.injectIntoGlobalHook(window)
          window.$RefreshReg$ = () => {}
          window.$RefreshSig$ = () => (type) => type
          window.__vite_plugin_react_preamble_installed__ = true
        JAVASCRIPT
      end

      it 'returns react-refresh tag' do
        tag = subject.vite_react_refresh_tag(helper, nonce:)
        expect(tag.to_s).to eq(helper.javascript_tag(react_refresh, type: :module, nonce:))
      end
    end

    describe '#vite_javascript_tag' do
      it 'generates a simple include tag' do
        tag = subject.vite_javascript_tag(helper, 'application.ts')
        expect(tag.to_s).to eq('<script src="/packs-dev/entrypoints/application.ts" crossorigin="" type="module"></script>')
      end
    end

    describe '#vite_stylesheet_tag' do
      it 'generates a simple link tag' do
        tag = subject.vite_stylesheet_tag(helper, 'styles/application.scss')
        expect(tag.to_s).to eq('<link rel="stylesheet" href="/packs-dev/styles/application.scss" />')
      end
    end

    describe '#vite_asset_path' do
      it 'returns full path to asset' do
        expect(subject.vite_asset_path(helper, 'icons/main.png')).to eq('/packs-dev/icons/main.png')
      end
    end

    describe '#vite_polyfills_tag' do
      it 'returns an empty string' do
        expect(subject.vite_polyfills_tag(helper)).to eq('')
      end
    end

    describe '#vite_preload_file_tag' do
      it 'returns a preload link tag' do
        tag = subject.vite_preload_file_tag(helper, 'mastodon/locales/en-GB.json')
        expect(tag.to_s).to eq('<link rel="modulepreload" href="/packs-dev/mastodon/locales/en-GB.json" as="script" crossorigin="anonymous">')
      end
    end
  end

  context 'with :manifest strategy' do
    let(:config) do
      Vite::Config.new({
        auto_build: false,
        manifest_path: manifest_path,
        manifest_assets_path: manifest_assets_path,
        base_path: '/packs-dev/',
        tag_strategies: [:manifest],
      })
    end

    let(:dev_server) do
      Class.new do
        def self.running?
          false
        end
      end
    end

    describe '#vite_client_tag' do
      it 'returns an empty string' do
        expect(subject.vite_client_tag(helper)).to eq('')
      end
    end

    describe '#vite_react_refresh_tag' do
      it 'returns an empty string' do
        expect(subject.vite_react_refresh_tag(helper)).to eq('')
      end
    end

    describe '#vite_javascript_tag' do
      let(:expected) do
        '<script src="/packs-dev/application.js" crossorigin="" type="module"></script>' \
          '<link rel="modulepreload" href="/packs-dev/no-deps.js" as="script" crossorigin="" integrity="abc-3">' \
          '<link rel="modulepreload" href="/packs-dev/dep-1-1.js" as="script" crossorigin="" integrity="abc-6">' \
          '<link rel="modulepreload" href="/packs-dev/dep-1-2.js" as="script" crossorigin="" integrity="abc-7">' \
          '<link rel="modulepreload" href="/packs-dev/dep-1.js" as="script" crossorigin="" integrity="abc-4">' \
          '<link rel="modulepreload" href="/packs-dev/dep-2.js" as="script" crossorigin="" integrity="abc-5">' \
          '<link rel="stylesheet" crossorigin="" href="/packs-dev/assets/dep-1-1.css" />' \
          '<link rel="stylesheet" crossorigin="" href="/packs-dev/assets/dep-1.css" />' \
          '<link rel="stylesheet" crossorigin="" href="/packs-dev/assets/dep-2.css" />' \
          '<link rel="stylesheet" crossorigin="" href="/packs-dev/assets/main.css" />' \
          '<link rel="stylesheet" crossorigin="" href="/packs-dev/assets/unlisted.css" />'
      end

      it 'returns tags for the main javascript module and its dependencies' do
        tag = subject.vite_javascript_tag(helper, 'application.ts')
        expect(tag.to_s).to eq(expected)
      end
    end

    describe '#vite_stylesheet_tag' do
      it 'returns stylesheet link tag to the bundled asset' do
        tag = subject.vite_stylesheet_tag(helper, 'styles/entrypoints/inert.scss')
        expect(tag.to_s).to eq('<link rel="stylesheet" href="/packs-dev/assets/inert-xyz.css" />')
      end
    end

    describe '#vite_asset_path' do
      it 'returns path to the bundled asset' do
        expect(subject.vite_asset_path(helper, 'icons/main.png')).to eq('/packs-dev/assets/main-abc.png')
      end
    end

    describe '#vite_polyfills_tag' do
      it 'returns include tag to polyfill module' do
        tag = subject.vite_polyfills_tag(helper)
        expect(tag.to_s).to eq('<script src="/packs-dev/polyfills.js" crossorigin="anonymous" type="module"></script>')
      end
    end

    describe '#vite_preload_file_tag' do
      it 'returns a preload link tag to bundled asset' do
        tag = subject.vite_preload_file_tag(helper, 'mastodon/locales/en-GB.json')
        expect(tag.to_s).to eq('<link rel="modulepreload" href="/packs-dev/intl/en-GB.js" as="script" crossorigin="anonymous" integrity="abc-1">')
      end
    end
  end

  context 'with both strategies' do
    let(:config) do
      Vite::Config.new({
        auto_build: false,
        manifest_path: manifest_path,
        manifest_assets_path: manifest_assets_path,
        base_path: '/packs-dev/',
        tag_strategies: [:dev_server, :manifest],
      })
    end

    context 'when the dev server is running' do
      let(:dev_server) do
        Class.new do
          def self.running?
            true
          end
        end
      end

      it 'uses :dev_server strategy' do
        expect(subject.vite_client_tag(helper)).to_not be_empty
      end
    end

    context 'when the dev server is not running' do
      let(:dev_server) do
        Class.new do
          def self.running?
            false
          end
        end
      end

      it 'uses :manifest strategy' do
        expect(subject.vite_client_tag(helper)).to be_empty
      end
    end
  end
end
