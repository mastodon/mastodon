# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormattingHelper do
  include Devise::Test::ControllerHelpers

  describe '#rss_status_content_format' do
    subject { helper.rss_status_content_format(status) }

    context 'with a simple status' do
      let(:status) { Fabricate.build :status, text: 'Hello world' }

      it 'renders the formatted elements' do
        expect(parsed_result.css('p').first.text)
          .to eq('Hello world')
      end
    end

    context 'with a spoiler and an emoji and a poll' do
      let(:status) { Fabricate(:status, text: 'Hello :world: <>', spoiler_text: 'This is a spoiler<>', poll: Fabricate.build(:poll, options: %w(Yes<> No))) }

      before { Fabricate :custom_emoji, shortcode: 'world' }

      it 'renders the formatted elements' do
        expect(spoiler_node.css('strong').text)
          .to eq('Content warning:')
        expect(spoiler_node.text)
          .to include('This is a spoiler<>')
        expect(content_node.text)
          .to eq('Hello  <>')
        expect(content_node.css('img').first.to_h.symbolize_keys)
          .to include(
            rel: 'emoji',
            title: ':world:'
          )
        expect(poll_node.css('radio').first.text)
          .to eq('Yes<>')
        expect(poll_node.css('radio').first.to_h.symbolize_keys)
          .to include(
            disabled: 'disabled'
          )
      end

      def spoiler_node
        parsed_result.css('p').first
      end

      def content_node
        parsed_result.css('p')[1]
      end

      def poll_node
        parsed_result.css('p').last
      end
    end

    def parsed_result
      Nokogiri::HTML.fragment(subject)
    end
  end
end
