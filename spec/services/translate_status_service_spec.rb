# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslateStatusService do
  subject(:service) { described_class.new }

  let(:status) { Fabricate(:status, text: text, spoiler_text: spoiler_text, language: 'en', preloadable_poll: poll, media_attachments: media_attachments) }
  let(:text) { 'Hello' }
  let(:spoiler_text) { '' }
  let(:poll) { nil }
  let(:media_attachments) { [] }

  before do
    Fabricate(:custom_emoji, shortcode: 'highfive')
  end

  describe '#call' do
    before do
      translation_service = TranslationService.new
      allow(translation_service).to receive(:languages).and_return({ 'en' => ['es', 'es-MX'] })
      allow(translation_service).to receive(:translate) do |texts|
        texts.map do |text|
          TranslationService::Translation.new(
            text: text.gsub('Hello', 'Hola').gsub('higfive', 'cincoaltos'),
            detected_source_language: 'en',
            provider: 'Dummy'
          )
        end
      end

      allow(TranslationService).to receive_messages(configured?: true, configured: translation_service)
    end

    it 'returns translated status content and source language and provider and original status' do
      expect(service.call(status, 'es'))
        .to have_attributes(
          content: '<p>Hola</p>',
          detected_source_language: 'en',
          language: 'es',
          provider: 'Dummy',
          status: status
        )
    end

    describe 'status has content with custom emoji' do
      let(:text) { 'Hello & :highfive:' }

      it 'does not translate shortcode' do
        expect(service.call(status, 'es').content).to eq '<p>Hola &amp; :highfive:</p>'
      end
    end

    describe 'status has no spoiler_text' do
      it 'returns an empty string' do
        expect(service.call(status, 'es').spoiler_text).to eq ''
      end
    end

    describe 'status has spoiler_text' do
      let(:spoiler_text) { 'Hello & Hello!' }

      it 'translates the spoiler text' do
        expect(service.call(status, 'es').spoiler_text).to eq 'Hola & Hola!'
      end
    end

    describe 'status has spoiler_text with custom emoji' do
      let(:spoiler_text) { 'Hello :highfive:' }

      it 'does not translate shortcode' do
        expect(service.call(status, 'es').spoiler_text).to eq 'Hola :highfive:'
      end
    end

    describe 'status has spoiler_text with unmatched custom emoji' do
      let(:spoiler_text) { 'Hello :Hello:' }

      it 'translates the invalid shortcode' do
        expect(service.call(status, 'es').spoiler_text).to eq 'Hola :Hola:'
      end
    end

    describe 'status has poll' do
      let(:poll) { Fabricate(:poll, options: ['Hello 1', 'Hello 2']) }

      it 'translates the poll option title' do
        status_translation = service.call(status, 'es')
        expect(status_translation.poll_options.size).to eq 2
        expect(status_translation.poll_options.first.title).to eq 'Hola 1'
      end
    end

    describe 'status has media attachment' do
      let(:media_attachments) { [Fabricate(:media_attachment, description: 'Hello & :highfive:')] }

      it 'translates the media attachment description' do
        status_translation = service.call(status, 'es')

        media_attachment = status_translation.media_attachments.first
        expect(media_attachment.id).to eq media_attachments.first.id
        expect(media_attachment.description).to eq 'Hola & :highfive:'
      end
    end

    describe 'target language is regional' do
      it 'uses regional variant' do
        expect(service.call(status, 'es-MX').language).to eq 'es-MX'
      end

      it 'uses parent locale for unsupported regional variant' do
        expect(service.call(status, 'es-XX').language).to eq 'es'
      end
    end
  end

  describe '#source_texts' do
    before do
      service.instance_variable_set(:@status, status)
    end

    describe 'status only has content' do
      it 'returns formatted content' do
        expect(service.send(:source_texts)).to eq({ content: '<p>Hello</p>' })
      end
    end

    describe 'status content contains custom emoji' do
      let(:status) { Fabricate(:status, text: 'Hello :highfive:') }

      it 'returns formatted content' do
        source_texts = service.send(:source_texts)
        expect(source_texts[:content]).to eq '<p>Hello <span translate="no">:highfive:</span></p>'
      end
    end

    describe 'status content contains tags' do
      let(:status) { Fabricate(:status, text: 'Hello #hola') }

      it 'returns formatted content' do
        source_texts = service.send(:source_texts)
        expect(source_texts[:content]).to include '<p>Hello <a'
        expect(source_texts[:content]).to include '/tags/hola'
      end
    end

    describe 'status has spoiler text' do
      let(:status) { Fabricate(:status, spoiler_text: 'Hello :highfive:') }

      it 'returns formatted spoiler text' do
        source_texts = service.send(:source_texts)
        expect(source_texts[:spoiler_text]).to eq 'Hello <span translate="no">:highfive:</span>'
      end
    end

    describe 'status has poll' do
      let(:poll) { Fabricate(:poll, options: %w(Blue Green)) }

      context 'with source texts from the service' do
        let!(:source_texts) { service.send(:source_texts) }

        it 'returns formatted poll options' do
          expect(source_texts)
            .to have_attributes(
              size: 3,
              values: %w(<p>Hello</p> Blue Green),
              keys: contain_exactly(
                eq(:content),
                be_a(Poll::Option).and(have_attributes(id: '0', title: 'Blue')),
                be_a(Poll::Option).and(have_attributes(id: '1', title: 'Green'))
              )
            )
        end
      end
    end

    describe 'status has poll with custom emoji' do
      let(:poll) { Fabricate(:poll, options: ['Blue', 'Green :highfive:']) }

      it 'returns formatted poll options' do
        html = service.send(:source_texts).values.last
        expect(html).to eq 'Green <span translate="no">:highfive:</span>'
      end
    end

    describe 'status has media attachments' do
      let(:text) { '' }
      let(:media_attachments) { [Fabricate(:media_attachment, description: 'Hello :highfive:')] }

      it 'returns media attachments without custom emoji rendering' do
        source_texts = service.send(:source_texts)
        expect(source_texts.size).to eq 1

        key, text = source_texts.first
        expect(key).to eq media_attachments.first
        expect(text).to eq 'Hello :highfive:'
      end
    end
  end

  describe '#wrap_emoji_shortcodes' do
    before do
      service.instance_variable_set(:@status, status)
    end

    describe 'string contains custom emoji' do
      let(:text) { ':highfive:' }

      it 'renders the emoji' do
        html = service.send(:wrap_emoji_shortcodes, 'Hello :highfive:'.html_safe)
        expect(html).to eq 'Hello <span translate="no">:highfive:</span>'
      end
    end
  end

  describe '#unwrap_emoji_shortcodes' do
    describe 'string contains custom emoji' do
      it 'inserts the shortcode' do
        fragment = service.send(:unwrap_emoji_shortcodes, '<p>Hello <span translate="no">:highfive:</span>!</p>')
        expect(fragment.to_html).to eq '<p>Hello :highfive:!</p>'
      end

      it 'preserves other attributes than translate=no' do
        fragment = service.send(:unwrap_emoji_shortcodes, '<p>Hello <span translate="no" class="foo">:highfive:</span>!</p>')
        expect(fragment.to_html).to eq '<p>Hello <span class="foo">:highfive:</span>!</p>'
      end
    end
  end
end
